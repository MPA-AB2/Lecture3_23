function [panorama] = image_stitch(J,mainImg)

% images = load(J);
% img = imread(mainImg);
img = mainImg;
img_gray = rgb2gray(mainImg);
images = J;
images_gray = {};
% images = images.J;

velikost =  size(images,2);
indexPairs = {};
matchmetric = {};

for i = 1:velikost
    images_gray{1,i}= rgb2gray(images{1,i});
end

indexy = 1:velikost;
temp_struct = images_gray;
rgb_struct = images;
while indexy
%     disp(indexy)
    num_of_pairs = [];
    sum_matchmetric = [];
    indexPairs = {};
    matchmetric = {};
    points = detectFASTFeatures(img_gray);
    [features,validPoints] = extractFeatures(img_gray,points);
    for i = 1:length(indexy)
        temp_img = temp_struct{1,i};
        points_temp_img = detectFASTFeatures(temp_img);
        [featurestemp_img,validPointstemp_img] = extractFeatures(temp_img,points_temp_img);
        [indexPairs{1,i},matchmetric{1,i}] = matchFeatures(features,featurestemp_img);
        num_of_pairs(i) = size(indexPairs{1, i},1);

        sum_matchmetric(i) = sum(matchmetric{1, i});

    end

    ind_max_pairs = find(num_of_pairs == max(num_of_pairs));
    if length(ind_max_pairs == 1)
        chosen_image = images{1,ind_max_pairs};
        indexy(ind_max_pairs) = [];
        chosen_index = ind_max_pairs;
    else
        ind_min_sum = find(sum_matchmetric == min(sum_matchmetric));
        chosen_image = images{1,ind_min_sum};
        if length(ind_min_sum) > 1
            chosen_image = images{1,ind_min_sum(1)};
            indexy(ind_min_sum(1)) = [];
            chosen_index = ind_min_sum;
        end
        indexy(ind_min_sum) = [];
        chosen_index = ind_min_sum;
    end
    points_temp_img = detectFASTFeatures(temp_struct{1,chosen_index});
    [featurestemp_img,validPointstemp_img] = extractFeatures(temp_struct{1,chosen_index},points_temp_img);
    indexPairs = matchFeatures(features,featurestemp_img);

    ip = indexPairs;

    mp1 = validPoints(ip(:,1),:); 
    mp2 = validPointstemp_img(ip(:,2),:);

    x = round(median(mp1.Location(:,1) - mp2.Location(:,1)));
    y = round(median(mp1.Location(:,2) - mp2.Location(:,2)));

    img(y:y+size(rgb_struct{1,chosen_index},1)-1,x:x+size(rgb_struct{1,chosen_index},2)-1,:) = rgb_struct{1,chosen_index};
    img_gray(y:y+size(temp_struct{1,chosen_index},1)-1,x:x+size(temp_struct{1,chosen_index},2)-1,:) = temp_struct{1,chosen_index};

    temp_struct = {};
    rgb_struct = {};
    for j = 1:length(indexy)
        temp_struct{1,j} = images_gray{1,indexy(j)};
        rgb_struct{1,j} = images{1,indexy(j)};
    end
    
end

panorama = img;
end