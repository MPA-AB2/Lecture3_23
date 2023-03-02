close all; clear all;
panorama = imread("Lecture3_data\panorama.png");
imshow(panorama)
gray_panorama = rgb2gray(panorama);
load("Lecture3_data\image_splitted.mat");

figure
sift_points = cell(1, length(J));
kaze_points = cell(1, length(J));
for i = 1:length(J)
    subplot(2,4,i)
    imshow(J{i})
    sift_points{i} = detectSIFTFeatures(rgb2gray(J{i}), "ContrastThreshold", 0.045);
    kaze_points{i} = detectKAZEFeatures(rgb2gray(J{i}), "Threshold", 0.001);
    hold on
    plot(sift_points{i}.Location(:, 1), sift_points{i}.Location(:, 2), "xr")
    plot(kaze_points{i}.Location(:, 1), kaze_points{i}.Location(:, 2), "xb")
end


mask = zeros(size(gray_panorama), "uint8");
mask(gray_panorama > 0) = 1;



