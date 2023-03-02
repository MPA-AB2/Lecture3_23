function [output_panorama] = image_stitch(image_splitted,color_im)
%nacteni obrazu
%color_im = imread('Lecture3_data/panorama.png');
%image_splitted = load('Lecture3_data/image_splitted.mat');
output_panorama = color_im;
obr = rgb2gray(color_im);

%index cyklu
cycle_idx = 1:1:size(image_splitted,2);


%%
for k = 1: size(image_splitted,2)
    %ulozeni parametru puvodniho obrazu
    corners_obr = detectORBFeatures(obr);
    [features_obr,valid_corners_obr] = extractFeatures(obr,corners_obr);
    
    %vyber nejpodobnejsiho obrazu
    imidx = 1;
    findist = Inf;
    %features_fin = [];
    valid_corners_fin = [];
    
    
    for j = cycle_idx(cycle_idx ~= 0)
        im_current = rgb2gray(image_splitted{j});
        %harrisova vzdalenost
        corners_im_current = detectORBFeatures(im_current);
        [features_im_current,valid_corners_im_current] = extractFeatures(im_current,corners_im_current);
    
        %eukleidovska vzdalenostni matice
        edist = pdist2(features_obr.Features, features_im_current.Features);
        if min(min(edist))<min(min(findist))
            findist = edist;
            imidx = j;
            %features_fin = features_im_current;
            valid_corners_fin = valid_corners_im_current;
        end
    end
    
    cycle_idx(imidx) =0;
    finim = rgb2gray(image_splitted{imidx});
    %%
    %vyber n nejlepsich bodu
    npoints = 1;
    
    pos_idx_obr = zeros(1,npoints);
    pos_idx_im_current = zeros(1,npoints);
    
    for i = 1:npoints
        [val,pos1] = min(findist);
        [~,pos2] = min(val);
        pos_idx_obr(i) = pos1(pos2);
        pos_idx_im_current(i) = pos2;
        findist(pos_idx_obr(i),pos_idx_im_current(i)) = Inf;
    end
    
    %%
    %indexace pozic bodu
    obr_points_pos = valid_corners_obr.Location(pos_idx_obr,:);
    im_current_points_pos = valid_corners_fin.Location(pos_idx_im_current,:);
    
    %%
    %figure
    %imshow(obr)
    %hold on
    %plot(obr_points_pos(:,1),obr_points_pos(:,2))
    %figure
    %imshow(finim)
    %hold on
    %plot(im_current_points_pos(:,1),im_current_points_pos(:,2))
    
    %%
    color_other = (image_splitted{imidx});
    %licovani
    %scaling=[V1.Location(pos_Start(1),2)-V2.Location(pos_test(1),2),V1.Location(pos_Start(1),1)-V2.Location(pos_test(1),1)];
    %V1 - valid_points startovního obrázku; V2-valid_points testovaného obr.
    %pos_start - pozice stejných features u start.obr.;pos_test - pozice
    %stejných features u test.obr.
    %start(scaling(1):R+scaling(1)-1,scaling(2):C+scaling(2)-1)=test_zaloha;
    %R - rows u start obr a C - col. u start obr
    %test_zaloha je puvodni testovaci obr
    scaling=[floor(mean(obr_points_pos(:,2)-im_current_points_pos(:,2))),floor(mean(obr_points_pos(:,1)-im_current_points_pos(:,1)))];
    obr(scaling(1):size(finim,1)+scaling(1)-1,scaling(2):size(finim,2)+scaling(2)-1,:) = finim;
    output_panorama(scaling(1):size(finim,1)+scaling(1)-1,scaling(2):size(finim,2)+scaling(2)-1,:) = color_other;
    %figure
    %imshow(uint8(obr))
end
end