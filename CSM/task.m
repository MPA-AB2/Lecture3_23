% MPA-AB2 Excercise 3 - Image stiching
% Jakub Muller, Radek Chmela, David Sidlo
% Loading data

% input imageSplit must be 1xn ! (if condition)



close all; clear all; clc
imgRef= imread('panorama.png'); 
% imgRef = rgb2gray(im2double(imgRef));
load('image_splitted.mat')
imgSplit = J;
clear J;

%% KAZE approach
% pointsRef = zeros(size(imgRef,1),2);
pointsRef = detectKAZEFeatures(imgRef,'Diffusion','region');

imgTemp = rgb2gray(im2double(imgSplit{1,1}));
pointsSplit = detectKAZEFeatures(imgTemp,'Diffusion','region');
strongestSplit1 = selectStrongest(pointsSplit,10);

% for i = 1:length(imgSplit)
%     imgTemp = rgb2gray(im2double(imgSplit{1,i}));
%     pointsSplit = detectKAZEFeatures(imgTemp,'Diffusion','region');
% 
% end
%% 
strongest = selectStrongest(pointsRef,10);

 imshow(imgRef);
 hold on;

plot(strongest);
hold on;


%% 

close all; clear all; clc
imgRef= imread('panorama.png'); 
% imgRef = rgb2gray(im2double(imgRef));
load('image_splitted.mat')
imgSplit = J;
clear J;
%

% Load input images
im1 = imgRef;
im2 = imgSplit{1,3};

% Convert images to grayscale
im1_gray = im2double(rgb2gray(im1));
im2_gray = im2double(rgb2gray(im2));

% Detect and extract KAZE features from each image
points1 = detectKAZEFeatures(im1_gray);
[features1, points1] = extractFeatures(im1_gray, points1);

points2 = detectKAZEFeatures(im2_gray);
[features2, points2] = extractFeatures(im2_gray, points2);

% Match KAZE features between adjacent images
indexPairs = matchFeatures(features1, features2);

% Compute geometric transformation between matched features

matchedPoints1 = points1(indexPairs(:, 1));
matchedPoints2 = points2(indexPairs(:, 2));

tform = estimateGeometricTransform(matchedPoints2, matchedPoints1, 'affine');

% Warp one image onto the other
im2_warped = imwarp(im2, tform);



%%


desired_size = [size(im1,1), size(im1,2)];

pad_size = [desired_size(1,1)-size(im2_gray,1),desired_size(1,2)-size(im2_gray,2)]; 
im2_warped = padarray(im2_gray, round(pad_size/2,"TieBreaker","tozero"), 'both');
im2_warped = imresize(im2_gray,[size(im1,1), size(im1,2)]);

%%
% Blend the warped images together
im_stitched = imblend(im2double(im1), im2double(im2_warped),1,'overlay',0);

% Display stitched image
imshow(im_stitched);
