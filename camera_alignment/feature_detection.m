close all;

% load images
img_left = rgb2gray(imread('clip04-01-left.pbm'));
img_right = rgb2gray(imread('clip04-01-right.pbm'));

img_left = imresize(img_left, 0.22);
img_right = imresize(img_right, 0.22);

% detect features
points_left = detectSURFFeatures(img_left);
points_right = detectSURFFeatures(img_right);

% extract features
[features_left, points_left] = extractFeatures(img_left, points_left);
[features_right, points_right] = extractFeatures(img_right, points_right);

% match features
featuresPairs = matchFeatures(features_left, features_right);

% filter matched pairs
matched_points_left = points_left(featuresPairs(:, 1), :);
matched_points_right = points_right(featuresPairs(:, 2), :);

% display matched pairs
figure;
showMatchedFeatures(img_left, img_right, ...
                    matched_points_left, matched_points_right, 'montage');
title('Putatively Matched Points (Including Outliers)');

% find fundamental matrix and eliminate outliers
[F, inliers_indices] = estimateFundamentalMatrix(matched_points_right, matched_points_left);
F

% display pairs without outliers
figure;
showMatchedFeatures(img_left, img_right, ...
    matched_points_left(inliers_indices,:), matched_points_right(inliers_indices,:), ...
    'montage','PlotOptions',{'ro','go','y--'});
title('Point matches after outliers were removed');

