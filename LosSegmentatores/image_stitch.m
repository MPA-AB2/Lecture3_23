function [panorama] = image_stitch(J,initPanorama)

Jorig = J;
for i = 1:length(J)
    J{i} = rgb2gray(J{i});
end
%%
while ~isempty(J)
    % cropping the panorama
    initPanoramaGray = rgb2gray(initPanorama);
    indd=find(initPanoramaGray);
    [row,col] = ind2sub(size(initPanoramaGray),indd);
    croppedPanorama = im2double(initPanoramaGray(min(row):max(row),min(col):max(col)));

    % finding regions for correlation
    im = cell(5,1);
    SumCorr = [];
    MaxCorr = [];
    [nr,nc] = size(croppedPanorama);
    croop_size_x = floor(nr/5);
    croop_size_y = floor(nr/5);
    % find image patches at current panorama border
    if sum(croppedPanorama==0,'all')>0
        im = cell(15,1);
        edges = edge(croppedPanorama==0,"canny");
        edgePoints = find(edges);
        [edgePointsRow,edgePointsCol] = ind2sub(size(croppedPanorama),edgePoints);
        for i = 1:10
            ind = randi([1,length(edgePoints)],1,1);
            while edgePointsRow(ind)>(nr-croop_size_x) || edgePointsCol(ind)>(nc-croop_size_y)
                ind = randi([1,length(edgePoints)],1,1);
            end
            im{i} = croppedPanorama(edgePointsRow(ind):(edgePointsRow(ind)+croop_size_x),edgePointsCol(ind):(edgePointsCol(ind)+croop_size_y));

            for j = 1:length(J)
                SumCorr(i,j) = sum(xcorr2(J{j},im{i}),'all');
                MaxCorr(i,j) = max(xcorr2(J{j},im{i}),[],'all');
            end
        end

    end
    % find other random image patches
    for i = 1:5
        x = randi([1,nr-croop_size_x],1,1);
        y = randi([1,nc-croop_size_y],1,1);
        if length(im) == 10
            im{i} = croppedPanorama(x:(x+croop_size_x),y:(y+croop_size_y));
        else
            im{i+10} = croppedPanorama(x:(x+croop_size_x),y:(y+croop_size_y));
        end
%         while sum(im{i},'all') == 0
%             x = randi([1,nr-croop_size_x],1,1);
%             y = randi([1,nc-croop_size_y],1,1);
%             if length(im) == 5
%                 im{i} = croppedPanorama(x:(x+croop_size_x),y:(y+croop_size_y));
%             else
%                 im{i+5} = croppedPanorama(x:(x+croop_size_x),y:(y+croop_size_y));
%             end
%         end
        for j = 1:length(J)
            if length(im) == 10
                SumCorr(i,j) = sum(xcorr2(J{j},im{i}),'all');
                MaxCorr(i,j) = max(xcorr2(J{j},im{i}),[],'all');
            else
                SumCorr(i+10,j) = sum(xcorr2(J{j},im{i+10}),'all');
                MaxCorr(i+10,j) = max(xcorr2(J{j},im{i+10}),[],'all');
            end
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

    % Select images
    imageToFuse = Jorig{FinalIdx};
    imageToFuseGray = J{FinalIdx};
    
    % Detect and extract features from both images
    points1 = detectSURFFeatures(imageToFuseGray);
    points2 = detectSURFFeatures(initPanoramaGray);
    
    [features1, validPoints1] = extractFeatures(imageToFuseGray, points1);
    [features2, validPoints2] = extractFeatures(initPanoramaGray, points2);
    
    % Match the features between the two images
    indexPairs = matchFeatures(features1, features2, 'Unique', true);
    
    % Retrieve the locations of the matched points in both images
    matchedPoints1 = validPoints1(indexPairs(:,1),:);
    matchedPoints2 = validPoints2(indexPairs(:,2),:);
    
    % if there is not enough matched points, try the other image
    if length(indexPairs) < 3 && length(J) > 1
        % Select images
        [FinalIdx,~]=intersect(IdxMax2,IdxSum2);
        FinalIdx = FinalIdx(2);
        imageToFuse = Jorig{FinalIdx};
        imageToFuseGray = J{FinalIdx};
        
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
    end

    % Find the transformation matrix between the two images
    tform = estimateGeometricTransform(matchedPoints1, matchedPoints2, 'affine','Confidence', 95, 'MaxNumTrials', 2000);
    
    % Create a panorama by combining the two images using the transformation matrix
    outputView = imref2d(size(initPanoramaGray));
    warpedPanorama = imwarp(imageToFuse, tform, 'OutputView', outputView);
    initPanorama = max(initPanorama, warpedPanorama); % overlay image1 over image2

    % remove fused image
    J(FinalIdx) = [];
    Jorig(FinalIdx) = [];
end
panorama = initPanorama;
end