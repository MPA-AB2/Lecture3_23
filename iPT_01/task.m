

close all;clear all;clc;

addpath(genpath('V:\AB2\Lecture3_23'))
load('image_splitted.mat');

panorama=imread('panorama.png');

%% Im crop
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
%imshow(croppedImage);

size_crop=size(croppedImage);
panorama_crop=croppedImage(1:size_crop(1)-1,1:size_crop(2)-1,:);
%imshow(panorama_crop);



%% Feature detection-points


size_J=size(J);
%J{size_J(2)+1}=panorama_crop;
J{size_J(2)+1}=panorama;


J_points=cell(1,size_J(2)+1);
J_features=cell(1,size_J(2)+1);
J_valid_points=cell(1,size_J(2)+1);

for i=1:size_J(2)+1 %point detection and feature extraction
    actual_image=rgb2gray(J{i});
    points = detectKAZEFeatures(actual_image);
    J_points{i}=selectStrongest(points,250);

     [features,valid_points] = extractFeatures(actual_image,points);
     J_features{i}=features;
     J_valid_points{i}=valid_points;
end

indexPairs = matchFeatures(J_features{2},J_features{8});

indexPairs=cell(size_J(2)+1);
matchedPoints1=cell(size_J(2)+1);
matchedPoints2=cell(size_J(2)+1);

for i=1:size_J(2)+1 %% match
    for j=1:1:size_J(2)+1

        indexPairs{i,j} = matchFeatures(J_features{i},J_features{j});
        matchedPoints1{i,j} = J_valid_points{i}(indexPairs{i,j}(:,1),:);
        matchedPoints2{i,j}= J_valid_points{j}(indexPairs{i,j}(:,2),:);
                
    end
end

max_count=zeros(size_J(2)+1);
max_count_ij=cell(size_J(2)+1);
for i=1:size_J(2)+1 %maximum similarity
    for j=1:size_J(2)+1
        if i~=j
            
            max_count(i,j)=matchedPoints1{i,j}.Count;
            max_count_ij{i,j}=[i j];

%             if max_count<matchedPoints1{i,j}.Count
%                 max_count=matchedPoints1{i,j}.Count;
%                 max_count_ij=[i j];

%             end
        end
    end
end



counter=size_J(2)+1;
poz_predchozi=0;
poz2_predchozi=0;
for i_velky=1:size_J(2)+1 %merging

    maximum=max(max(max_count(counter,:)));
    [im1,im2]=find(max_count==maximum);

    %im1=9
    %im2=2

    
    matchedPoints1_pom=round(matchedPoints1{im1, im2}.Location);
    matchedPoints2_pom=round(matchedPoints2{im1, im2}.Location);

   

    poz=double(matchedPoints1_pom(3,1)-matchedPoints2_pom(3,1))+poz_predchozi;
    poz2=double(matchedPoints1_pom(3,2)-matchedPoints2_pom(3,2))+poz2_predchozi;
    size_im=size(J{im2});
    panorama(poz2:poz2+double(size_im(1))-1,poz:poz+double(size_im(2))-1,:)=J{im2};
    %im_pom=J{im2};


    %panorama(249:249+size_im(1)-1,572:572+size_im(2)-1,:)=J{im2};

    imshow(panorama)


%     [tform,inlier_points1,inlier_points2] = estimateGeometricTransform(matchedPoints1{im1,im2},matchedPoints2{im1,im2},"similarity");
%     img1_warp=imwarp(J{im1},tform);
%     
%     img2_warp=imwarp(J{im2},tform);
% 
%     im_fuse=imfuse(img1_warp,img2_warp,'blend','Scaling','none');
%     imshow(im_fuse)
    counter=im2
    poz_predchozi=poz
    poz2_predchozi=poz
end



% imshow(actual_image)
% hold on
% plot(selectStrongest(points,160))
% hold off

