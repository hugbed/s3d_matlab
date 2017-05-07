close all;

% load images
img_left = rgb2gray(imread('clip04-01-left.pbm'));
img_right = rgb2gray(imread('clip04-01-right.pbm'));

img_left = imresize(img_left, 0.22);
img_right = imresize(img_right, 0.22);

% detect features
points_left = detectSURFFeatures(img_left);
points_right = detectSURFFeatures(img_right);

% plot points
figure;
imshow(img_left); hold on;
plot(points_left.selectStrongest(10)); 
figure;
imshow(img_right); hold on;
plot(points_right.selectStrongest(10)); hold off;

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
% (do it with constrained F and robust estimation)
[F, inliers_indices] = estimateFundamentalMatrix(matched_points_right, matched_points_left, 'Method', 'RANSAC');

inliers_points_left = matched_points_left(inliers_indices, :);
inliers_points_right = matched_points_right(inliers_indices, :);

% display pairs without outliers
figure;
showMatchedFeatures(img_left, img_right, ...
    inliers_points_left, inliers_points_right, ...
    'montage','PlotOptions',{'ro','go','y--'});
title('Point matches after outliers were removed');

% center the points
x = inliers_points_left.Location;
xp = inliers_points_right.Location;

WIDTH = size(img_left, 2);
HEIGHT = size(img_left, 1);
N = size(x(:, 1));

u = x(:,1) - WIDTH/2 * ones(N);
v = x(:,2) - HEIGHT/2 * ones(N);
up = xp(:,1) - WIDTH/2 * ones(N);
vp = xp(:,2)- HEIGHT/2 * ones(N);

% solve linear system of equations with SVD
A = [up - u, up, vp, -ones(size(up)), up.*v, -v.*vp, u.*vp - up.*v];
x = pinv(A)*(vp - v);

% decompose solution into parameters
ch_y = x(1) % percent?
a_z = rad2deg(x(2)) % degrees
a_f = (x(3) + 1) * 100 % percent
f_a_x = x(4);
a_y_f = x(5);
a_x_f = x(6);
ch_z_f = x(7);
