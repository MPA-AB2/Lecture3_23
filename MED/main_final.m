close all;
clear all;
load('image_splitted.mat');
init_pano = imread('panorama.png');
panorama = MED(J,init_pano);

%%
[PIQE,mError] = evalPanorama(panorama)
