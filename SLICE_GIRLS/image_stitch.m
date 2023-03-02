function panorama = image_stitch(J,image)

J = [image, J];
features = cell(1,9);
validPoints = cell(1,9);

% Detect features
for i = 1:length(J)
    im = im2double(rgb2gray(J{i}));
    points = detectKAZEFeatures(im, 'Diffusion', 'sharpedge', 'Threshold', 0.001);
    [features{1,i}, validPoints{1,i}] = extractFeatures(im, points);
end

maxIter = 9;

% Match features
for i = 1:8
    
    indexPairsAll = cell(1,maxIter);
    matchMetricAll = zeros(1,maxIter);
    matchMetricAll(1) = Inf;
    
    % Match the images
    for j = 2:maxIter
        [indexPairs, matchMetric] = matchFeatures(features{1}, features{j});
        indexPairsAll{1,j} = indexPairs;
        matchMetricAll(j) = mean(matchMetric);
    end
    
    % Find the best match
    [~, bestIdx] = min(matchMetricAll);
    
    % Stitch the best match
    validPoints1 = validPoints{1};
    validPoints2 = validPoints{bestIdx};

    indexPairs = indexPairsAll{1,bestIdx};
    
    matchedPoints1 = validPoints1(indexPairs(:,1),:);
    matchedPoints2 = validPoints2(indexPairs(:,2),:);
    
    % Find deltax and deltay
    x = round(median(matchedPoints1.Location(:,1) - matchedPoints2.Location(:,1)));
    y = round(median(matchedPoints1.Location(:,2) - matchedPoints2.Location(:,2)));
    
    % Stich images
    J{1}(y:y+size(J{bestIdx},1)-1,x:x+size(J{bestIdx},2)-1,:) = J{bestIdx};
    
    % Delete stitched image
    J = [J(1:(bestIdx-1)), J((bestIdx+1):end)];
    features = [features(1:(bestIdx-1)), features((bestIdx+1):end)];
    validPoints = [validPoints(1:(bestIdx-1)), validPoints((bestIdx+1):end)];
    maxIter = maxIter - 1;
    
    % Recalculate features
    im = im2double(rgb2gray(J{1}));
    points = detectKAZEFeatures(im, 'Diffusion', 'sharpedge', 'Threshold', 0.001);
    [features{1,1}, validPoints{1,1}] = extractFeatures(im, points);
    
end

panorama = J{1};

end