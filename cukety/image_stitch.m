function [im] = image_stitch(J, im)


% im = imread(init_panorama);
% load image_splitted.mat

% figure;
% for pointnumber = 1:8
%     subplot (2,4,pointnumber)
%     imshow(J{pointnumber})
% end
%
% figure
% imshow(im)
%% parameters
% detect features
th1 = 1000; %MetricThreshold — Strongest feature threshold
th2 = 1000;
no1 = 4;
no2 = 4;
% extract features
met1 = "SURF";
met2 = "SURF";

while ~isempty(J)

    %% Haaris features
    % https://www.mathworks.com/matlabcentral/answers/283233-how-to-combine-two-images-based-off-matched-features
    num_of_matchedpoints = zeros(1, size(J, 2));

    for i = 1:size(J, 2)
        I = im; %assign the first image to variable I;
        B = J{i};
        I1 = rgb2gray(I);
        B1 = rgb2gray(B);

 % Haaris features - https://www.mathworks.com/matlabcentral/answers/283233-how-to-combine-two-images-based-off-matched-features
%         points1 = detectHarrisFeatures(I1); %finds the corners
%         points2 = detectHarrisFeatures(B1);
        % SURF Features - Object Detection in a Cluttered Scene Using Point Feature Matching
        points1 = detectSURFFeatures(I1, "MetricThreshold", th1, "NumOctaves", no1);
        points2 = detectSURFFeatures(B1, "MetricThreshold", th2, "NumOctaves", no2);
        [features1, valid_points1] = extractFeatures(I1,points1,"Method",met1);
        [features2 valid_points2] = extractFeatures(B1,points2, "Method", met2);
        indexPairs = matchFeatures(features1,features2);
        matchedPoints1 = valid_points1(indexPairs(:,1),:);
        matchedPoints2 = valid_points2(indexPairs(:,2),:);
        %         figure; showMatchedFeatures(I1,B1,matchedPoints1,matchedPoints2);
        blender = vision.AlphaBlender('Operation', 'Binary mask', ...
            'MaskSource', 'Input port');

        num_of_matchedpoints(i) = size(matchedPoints1.Location, 1);
    end
    %% choose image

    [~, pos_max] = max(num_of_matchedpoints);

    %% again matched points

    I = im; %assign the first image to variable I;
    B = J{pos_max};
    I1 = rgb2gray(I);
    B1 = rgb2gray(B);
    % Haaris features - https://www.mathworks.com/matlabcentral/answers/283233-how-to-combine-two-images-based-off-matched-features
    %         points1 = detectHarrisFeatures(I1); %finds the corners
    %         points2 = detectHarrisFeatures(B1);
    % SURF Features - Object Detection in a Cluttered Scene Using Point Feature Matching
    points1 = detectSURFFeatures(I1, "MetricThreshold", th1, "NumOctaves", no1);
    points2 = detectSURFFeatures(B1, "MetricThreshold", th2, "NumOctaves", no2);
    [features1, valid_points1] = extractFeatures(I1,points1,"Method",met1);
    [features2 valid_points2] = extractFeatures(B1,points2,"Method",met2);
    indexPairs = matchFeatures(features1,features2);
    matchedPoints1 = valid_points1(indexPairs(:,1),:);
    matchedPoints2 = valid_points2(indexPairs(:,2),:);
%     figure; showMatchedFeatures(I1,B1,matchedPoints1,matchedPoints2);
    blender = vision.AlphaBlender('Operation', 'Binary mask', ...
        'MaskSource', 'Input port');

    num_of_matchedpoints(i) = size(matchedPoints1.Location, 1);

    %% registration of images

    loc1 = matchedPoints1.Location;% matchedPoints1 stores the corner points on Image1
    loc2 = matchedPoints2.Location;

    x_posun = loc1(:,1)-loc2(:,1);
    y_posun = loc1(:,2)-loc2(:,2);
    x_posun = median(floor(x_posun));
    y_posun = median(floor(y_posun));

    im33 = uint8(zeros(size(im)));

    im33(y_posun:y_posun+size(J{pos_max},1)-1,x_posun:x_posun+size(J{pos_max},2)-1,1) = J{pos_max}(:,:,1);
    im33(y_posun:y_posun+size(J{pos_max},1)-1,x_posun:x_posun+size(J{pos_max},2)-1,2) = J{pos_max}(:,:,2);
    im33(y_posun:y_posun+size(J{pos_max},1)-1,x_posun:x_posun+size(J{pos_max},2)-1,3) = J{pos_max}(:,:,3);
    %     figure;imshow(im33)

    registered = im33;
    J(pos_max) = [];

    %     if ~isempty(matchedPoints2)
    %         t = fitgeotform2d(matchedPoints2.Location,matchedPoints1.Location,"similarity");
    %         Rfixed = imref2d(size(im));
    %         registered = imwarp(J{pos_max},t,OutputView=Rfixed);
    %         imshowpair(im,registered,"blend");
    %         J(pos_max) = []
    %     end

    %% fusion of images
    for r = 1:size(im, 1)
        for  c = 1:size(im,2)
            if all(im(r,c,:) == 0)
                im(r,c,1)=registered(r,c,1);
                im(r,c,2)=registered(r,c,2);
                im(r,c,3)=registered(r,c,3);
            end
        end
    end

%     figure;imshow(im)

end

%% evaluation
% load image_splitted.mat
% [PIQE, err] = evalPanorama(im)
