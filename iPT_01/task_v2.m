% Load images.
% buildingDir = fullfile(toolboxdir('vision'),'visiondata','building');
% buildingScene = imageDatastore(buildingDir);

addpath(genpath('V:\AB2\Lecture3_23'))

load('image_splitted.mat');
panorama=imread('panorama.png');
size_J=size(J);
J{size_J(2)+1}=panorama;

rawImage = panorama;
% use some means to reduce the image to a 2D binary mask
% how this is done depends on what defines the background
if size(rawImage,3) == 3
    grayImage = rgb2gray(rawImage);
elseif size(rawImage,3) == 1
    grayImage = rawImage;
else
    error('not a supported image')
end
mask = grayImage > 0;
% segment the image, find the largest object
S = regionprops(mask,'BoundingBox','Area');
[MaxArea,MaxIndex] = max(vertcat(S.Area));
rect = S(MaxIndex).BoundingBox;
% Display the image; highlight the largest object
imshow(grayImage); hold on
rectangle('Position',rect,'LineWidth',1,'EdgeColor','y')
hold off

% Extract a cropped image from the original.
croppedImage = imcrop(rawImage,rect);
% Display the cropped image.
imshow(croppedImage);

size_crop=size(croppedImage);
panorama_crop=croppedImage(1:size_crop(1)-1,1:size_crop(2)-1,:);
imshow(panorama_crop);

J{size_J(2)+1}=panorama_crop;






% Display images to be stitched.
montage(J)

% Read the first image from the image set.
I = J{9};

% Initialize features for I(1)
grayImage = im2gray(I);
points = detectSURFFeatures(grayImage,'MetricThreshold',500);
[features, points] = extractFeatures(grayImage,points);

% Initialize all the transforms to the identity matrix. Note that the
% projective transform is used here because the building images are fairly
% close to the camera. Had the scene been captured from a further distance,
% an affine transform would suffice.
numImages = size_J(2);
tforms(numImages) = projective2d(eye(3));

% Initialize variable to hold image sizes.
imageSize = zeros(numImages,2);

% Iterate over remaining image pairs
for n = 2:numImages
    
    % Store points and features for I(n-1).
    pointsPrevious = points;
    featuresPrevious = features;
        
    % Read I(n).
    I = J{n};
    
    % Convert image to grayscale.
    grayImage = im2gray(I);    
    
    % Save image size.
    imageSize(n,:) = size(grayImage);
    
    % Detect and extract SURF features for I(n).
    points = detectSURFFeatures(grayImage,'MetricThreshold',500);    
    [features, points] = extractFeatures(grayImage, points);
  
    % Find correspondences between I(n) and I(n-1).
    indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
       
    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);        
    
    % Estimate the transformation between I(n) and I(n-1).
    tforms(n) = estimateGeometricTransform2D(matchedPoints, matchedPointsPrev,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
    
    % Compute T(n) * T(n-1) * ... * T(1)
    tforms(n).T = tforms(n).T * tforms(n-1).T; 
end


% Compute the output limits for each transform.
for i = 1:numel(tforms)           
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);    
end

avgXLim = mean(xlim, 2);
[~,idx] = sort(avgXLim);
centerIdx = floor((numel(tforms)+1)/2);
centerImageIdx = idx(centerIdx);

Tinv = invert(tforms(centerImageIdx));
for i = 1:numel(tforms)    
    tforms(i).T = tforms(i).T * Tinv.T;
end

for i = 1:numel(tforms)           
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);
end

maxImageSize = max(imageSize);

% Find the minimum and maximum output limits. 
xMin = min([1; xlim(:)]);
xMax = max([maxImageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([maxImageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', I);

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');  

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.
for i = 1:numImages
    
    I = readimage(buildingScene, i);   
   
    % Transform I into the panorama.
    warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
                  
    % Generate a binary mask.    
    mask = imwarp(true(size(I,1),size(I,2)), tforms(i), 'OutputView', panoramaView);
    
    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, mask);
end

figure
imshow(panorama)
