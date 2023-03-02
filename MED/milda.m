close all;
clear all;
load('image_splitted.mat');
mainImg = imread('panorama.png');
x = rgb2gray(mainImg);
imgsToFit = J;
fitedIndexes = zeros(1,length(imgsToFit));
fIndx = 1;
while (length(imgsToFit)-fIndx+1 ~= 0)
        %feater detection
    mainFeatures = detectKAZEFeatures(rgb2gray(mainImg));
    toFitFeatures = {};
    fix = 0;
    for i = 1:(length(imgsToFit))
        if (ismember(i,fitedIndexes))
            continue
        else
        toFitFeatures{i} =  detectKAZEFeatures(rgb2gray(imgsToFit{1,i}));
        end
    end
        %fitting best one
    myMax = 0;
    maxIndx = -1;
    matches = [];
    for i = 1:length(toFitFeatures)
       if (length(toFitFeatures{1,i})>0)
            [val,posA,posB]=intersect(mainFeatures.Metric,toFitFeatures{1,i}.Metric);
            if(length(val)>myMax) 
                myVals = val;
                myPosMain = posA;
                myPosToFit = posB;
                maxIndx = i;
                myMax = length(val);
            end
            matches(i) = length(val);
       end
    end
    if maxIndx == -1
        return;
    end
    %index handle
    fitedIndexes(fIndx) = maxIndx;
    fIndx = fIndx + 1;

    %fitting image
    thisImg = imgsToFit{1,maxIndx};
    matchedPoints1 = [mainFeatures.Location(myPosMain,1),mainFeatures.Location(myPosMain,2)];
    matchedPoints2 = [toFitFeatures{1,maxIndx}.Location(myPosToFit,1),toFitFeatures{1,maxIndx}.Location(myPosToFit,2)];
    ydif =  floor(matchedPoints1(1,1) - matchedPoints2(1,1));
    xdif =  floor(matchedPoints1(1,2) - matchedPoints2(1,2));
    mainImg(xdif:(xdif + size(thisImg,1)-1),ydif:(ydif + size(thisImg,2)-1),:) = thisImg;

    figure
    imshow(mainImg)
end