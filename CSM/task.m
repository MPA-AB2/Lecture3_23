clear
close all
clc
%
obr = imread("panorama.png");
obr = rgb2gray(obr);

% figure;
% imshow(obr)
%
images=load("image_splitted.mat");
%


for   i = 1:length(images.J)
    images.J{1,i} = rgb2gray(images.J{1,i});
end
%
dataset=cell(size(images.J));
for i= 1:size(dataset,2)
    pole= uint8(zeros(size(obr)));
    pole(1:size(images.J{i},1),1:size(images.J{i},2))=images.J{i};
    dataset{1,i}= pole;
end
%%
for obrazky= 1:length(dataset)


for p = 1:length(dataset)
    image = (dataset{1,p});
    points.J{1,p} = detectKAZEFeatures(image);
end

%
points1 = detectKAZEFeatures(obr);
[features1,valid_points1] = extractFeatures(obr,points1);
%

for pp = 1:length(dataset)
[features2.J{1,pp},valid_points2.J{1,pp}] = extractFeatures(dataset{1,pp},points.J{1,pp});
end

%
for ppp = 1:length(features2.J)
indexPairs.J{1,ppp} = matchFeatures(features1,features2.J{1,ppp});
end

% Ulozeni nejlepšího obrazku (indexPair a valid_points1)
delka=[];
for ip = 1:length(indexPairs.J)
    delka = [delka,length(indexPairs.J{ip})];
    [~,index]= max(delka);
end

the_best_index = indexPairs.J{index};
the_best_valid_points = valid_points2.J{index};
the_best_images = dataset{index};

%
matchedPoints1 = valid_points1(the_best_index(:,1),:);
%
matchedPoints2 = the_best_valid_points(the_best_index(:,2),:);
%
figure
showMatchedFeatures(obr,the_best_images,matchedPoints1,matchedPoints2);
figure
showMatchedFeatures(obr,the_best_images,matchedPoints1,matchedPoints2)
%
m=zeros(size(matchedPoints1.Location,1),2);
for j= 1:length(matchedPoints1)
    pom=matchedPoints1.Location(j,:)-matchedPoints2.Location(j,:);
    m(j,:)= pom;
end
posun_x=mean(m(:,1));
posun_y=mean(m(:,2));
%
pole= uint8(zeros(size(obr)));
pole(posun_y:posun_y+size(images.J{index},1)-1,posun_x:posun_x+size(images.J{index},2)-1)=images.J{index};
obr(posun_y:posun_y+size(images.J{index},1)-1,posun_x:posun_x+size(images.J{index},2)-1) = 0;
obr = obr+pole;

dataset{1,index}=uint8(zeros(size(obr)));

end
figure
imshow(obr)
figure
showMatchedFeatures(obr,pole,matchedPoints1,matchedPoints2);

