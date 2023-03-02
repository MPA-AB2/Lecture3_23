% MPA-AB2 - Lecture 3 
clear all,clc,close all
%% load images 
load('image_splitted.mat');
init_panorama = imread('panorama.png');
%% feed into our function
[panorama] = image_stitch(J,init_panorama);
imshow(panorama)
%% evaluate
[PIQE,mError] = evalPanorama(panorama);
%% save results
imwrite(panorama,'./finalPanorama.tiff');