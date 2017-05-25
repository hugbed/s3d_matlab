close all;

% load images
img_left_color = imread('clip04-01-left.pbm');
img_right_color = imread('clip04-01-right.pbm');
img_left = rgb2gray(img_left_color);
img_right = rgb2gray(img_right_color);
% img_left = imresize(img_left, 0.22);
% img_right = imresize(img_right, 0.22);
assert(size(img_left, 1) == size(img_right, 1));
assert(size(img_left, 2) == size(img_right, 2));

HEIGHT = size(img_left, 1)
WIDTH = size(img_left, 2)

% image shift
img_left_color = imtranslate(img_left_color,[-WIDTH*0.015, 0]);
img_right_color = imtranslate(img_right_color,[WIDTH*0.015, 0]);
img_left = imtranslate(img_left,[-WIDTH*0.015, 0]);
img_right = imtranslate(img_right,[WIDTH*0.015, 0]);

% find feature matches
[matched_pts1, matched_pts2] = find_matches(img_left, img_right);
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

% compute rectification matrices
% rectify images
% ...

% compute disparities
pts1 = matched_pts1(inliers).Location;
pts2 = matched_pts2(inliers).Location;

disparities = pts2(:, 1) - pts1(:, 1);

% to screen width percent
disparities = disparities ./ WIDTH * 100;

near_clip_plane_d = prctile(disparities, 2);
far_clip_plane_d = prctile(disparities, 99);

figure;
histogram(disparities, 10); hold on;
line([near_clip_plane_d near_clip_plane_d],[0 60], 'LineWidth', 2);
line([far_clip_plane_d far_clip_plane_d],[0 60], 'LineWidth', 2, 'Color', 'g');

disparity_range = far_clip_plane_d - near_clip_plane_d

% stereo anaglyph for comparison
figure; imshow(stereoAnaglyph(img_left, img_right));

% feature points colored depth (red, orange, green, blue, purple) from


% budget -> automatic sensor shift
budget_min = -1; % percent in front
budget_max = 2; % percent behind

budget_center = (budget_max + budget_min) / 2.0;

% budget -> convergence tips


% choose which parameters to fit

