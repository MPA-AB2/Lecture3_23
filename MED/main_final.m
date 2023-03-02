close all;
clear all;
load('image_splitted.mat');
init_pano = imread('panorama.png');
panorama = image_stitch(J,init_pano);

%%
[PIQE,mError] = evalPanorama(panorama)
