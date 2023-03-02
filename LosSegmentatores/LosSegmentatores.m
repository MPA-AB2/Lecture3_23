function [panorama] = LosSegmentatores(J,initPanorama)

Jorig = J;
initPanoramaGray = rgb2gray(initPanorama);
for i = 1:length(J)
    J{i} = rgb2gray(J{i});
end
%%
while ~isempty(J)
    % ořezání
    initPanoramaGray = rgb2gray(initPanorama);
    indd=find(initPanoramaGray);
    [row,col] = ind2sub(size(initPanoramaGray),indd);
    croppedPanorama = im2double(initPanoramaGray(min(row):max(row),min(col):max(col)));

    % nalezení oblastí ke korelaci
    
    [nr,nc] = size(croppedPanorama);
    croop_size_x = floor(nr/5);
    croop_size_y = floor(nr/5);
    im = cell(5,1);
    SumCorr = [];
    MaxCorr = [];
    for i = 1:5
        x = randi([1,nr-croop_size_x],1,1);
        y = randi([1,nc-croop_size_y],1,1);
        im{i} = croppedPanorama(x:(x+croop_size_x),y:(y+croop_size_y));
        while sum(im{i},'all')==0
            x = randi([1,nr-croop_size_x],1,1);
            y = randi([1,nc-croop_size_y],1,1);
            im{i} = croppedPanorama(x:(x+croop_size_x),y:(y+croop_size_y));
        end
        for j = 1:length(J)
            SumCorr(i,j) = sum(xcorr2(J{j},im{i}),'all');
            MaxCorr(i,j) = max(xcorr2(J{j},im{i}),[],'all');
        end
    end
    MaxCorr = mean(MaxCorr,1);
    SumCorr = mean(SumCorr,1); 
    [~,IdxMax] = max(MaxCorr);
    [~,IdxSum] = max(SumCorr);
    if IdxSum~=IdxMax
        [~,IdxMax2] = maxk(MaxCorr,2);
        [~,IdxSum2] = maxk(SumCorr,2);
        [FinalIdx,~]=intersect(IdxMax2,IdxSum2);
        if length(FinalIdx) > 1
            FinalIdx = FinalIdx(1);
        end
    else
        FinalIdx = IdxSum;
    end
    
%     figure
%     imshow(croppedPanorama)
%     figure
%     subplot 151
%     imshow(im{1})
%     subplot 152
%     imshow(im{2})
%     subplot 153
%     imshow(im{3})
%     subplot 154
%     imshow(im{4})
%     subplot 155
%     imshow(im{5})
% 
%     BestImage = J{i};

    % Select images
    imageToFuse = Jorig{FinalIdx};
    imageToFuseGray = J{FinalIdx};
    % image2Gray = J(:,:,2);
    
    % Detect and extract features from both images
    points1 = detectSURFFeatures(imageToFuseGray);
    points2 = detectSURFFeatures(initPanoramaGray);
    [features1, validPoints1] = extractFeatures(imageToFuseGray, points1);
    [features2, validPoints2] = extractFeatures(initPanoramaGray, points2);
    
    % Match the features between the two images
    indexPairs = matchFeatures(features1, features2, 'Unique', true);%, 'MaxRatio', 0.4, 'MatchThreshold',15
    
    % Retrieve the locations of the matched points in both images
    matchedPoints1 = validPoints1(indexPairs(:,1),:);
    matchedPoints2 = validPoints2(indexPairs(:,2),:);
    
    figure(1); 
%     showMatchedFeatures(imageToFuseGray,initPanoramaGray,matchedPoints1,matchedPoints2);
    imshow(Jorig{FinalIdx})
    
    % Find the transformation matrix between the two images
    tform = estimateGeometricTransform(matchedPoints1, matchedPoints2, 'affine','Confidence', 99, 'MaxNumTrials', 2000,'MaxDistance', 100);
    
    % Create a panorama by combining the two images using the transformation matrix
    outputView = imref2d(size(initPanoramaGray));
    warpedPanorama = imwarp(imageToFuse, tform, 'OutputView', outputView);
    initPanorama = max(initPanorama, warpedPanorama); % overlay image1 over image2
    
    % Display the resulting panorama
    figure(2);
    imshow(initPanorama);

    J(FinalIdx) = [];
    Jorig(FinalIdx) = [];
end
panorama = initPanorama;
end