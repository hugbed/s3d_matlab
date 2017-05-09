close all;

% load images
img_left = rgb2gray(imread('clip04-01-left.pbm'));
img_right = rgb2gray(imread('clip04-01-right.pbm'));

img_left = imresize(img_left, 0.22);
img_right = imresize(img_right, 0.22);

assert(size(img_left, 1) == size(img_right, 1));
assert(size(img_left, 2) == size(img_right, 2));

% detect features
points_left = detectSURFFeatures(img_left);
points_right = detectSURFFeatures(img_right);

% extract features
[features_left, points_left] = extractFeatures(img_left, points_left);
[features_right, points_right] = extractFeatures(img_right, points_right);

% match features
featuresPairs = matchFeatures(features_left, features_right);

% filter matched pairs
matched_pts1 = points_left(featuresPairs(:, 1), :);
matched_pts2 = points_right(featuresPairs(:, 2), :);

figure;
showMatchedFeatures(img_left, img_right, ...
                    matched_pts1, matched_pts2, 'montage');
title('Putatively Matched Points (Including Outliers)');

% estimate fundamental matrix parameters and eliminate outliers
[f, params, inliers] = estimate_rig_fundamental_matrix(matched_pts1, matched_pts2, size(img_left));

ch_y = params(1) % percent?
a_z = rad2deg(params(2)) % degrees
a_f = (params(3) + 1) * 100 % percent

figure;
showMatchedFeatures(img_left, img_right, ...
    matched_pts1(inliers), matched_pts2(inliers), ...
    'montage','PlotOptions',{'ro','go','y--'});
title('Point matches after outliers were removed');

figure;
showMatchedFeatures(img_left, img_right, ...
    matched_pts1(~inliers), matched_pts2(~inliers), ...
    'montage','PlotOptions',{'ro','go','y--'});
title('Rejected matches as outliers');