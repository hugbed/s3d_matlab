close all;

% choose dataset
dataset = 'Drive';

% load images
dir = strcat('data/', dataset);
img_left_color = imread(strcat(dir, '/', dataset, '_L.bmp'));
img_right_color = imread(strcat(dir, '/', dataset, '_R.bmp'));
img_left = rgb2gray(img_left_color);
img_right = rgb2gray(img_right_color);
% img_left = imresize(img_left, 0.22);
% img_right = imresize(img_right, 0.22);
assert(size(img_left, 1) == size(img_right, 1));
assert(size(img_left, 2) == size(img_right, 2));

HEIGHT = size(img_left, 1);
WIDTH = size(img_left, 2);

% display anaglyph
% figure; imshow(stereoAnaglyph(img_left, img_right));

% image shift
% img_left_color = imtranslate(img_left_color, [-WIDTH * 0.015, 0]);
% img_right_color = imtranslate(img_right_color, [WIDTH * 0.015, 0]);
% img_left = imtranslate(img_left, [-WIDTH * 0.015, 0]);
% img_right = imtranslate(img_right, [WIDTH * 0.015, 0]);

% find feature matches
[matched_pts1, matched_pts2] = find_matches(img_left, img_right);
figure;
showMatchedFeatures(img_left, ...
                    img_right, ...
                    matched_pts1, ...
                    matched_pts2, ...
                    'montage');
title('Putatively Matched Points (Including Outliers)');

% estimate fundamental matrix parameters and eliminate outliers
[f, params, inliers] = estimate_rig_fundamental_matrix(matched_pts1, matched_pts2, size(img_left));
figure;
showMatchedFeatures(img_left, ...
                    img_right, ...
                    matched_pts1(inliers), ...
                    matched_pts2(inliers), ...
                    'montage','PlotOptions',{'ro','go','y--'});
title('Point matches after outliers were removed');

% results
fprintf('Results:\n');
fprintf('\t vertical (degrees) = %f\n', params(1) * 180 / pi);
fprintf('\t roll (degrees) = %f\n', params(2) * 180 / pi);
fprintf('\t zoom (percent) = %f\n', (params(3) + 1.0) * 100.0);
fprintf('\t tiltOffset (percent) = %f\n', params(4));
fprintf('\t tiltKeystone (pixels) = %f\n', params(5));
fprintf('\t panKeystone (radians / m) = %f\n', params(6));
fprintf('\t zParallaxDeformation (m/m) = %f\n', params(7));

% epipolar lines


% rectify images
[img1_rectified, img2_rectified] = rectify_alignment(img_left, img_right, params);
% img1_rectified = imresize(img1_rectified, [HEIGHT, WIDTH]);
% img2_rectified = imresize(img2_rectified, [HEIGHT, WIDTH]);
figure;
subplot(1, 2, 1); imshow(img1_rectified);
subplot(1, 2, 2); imshow(img2_rectified);
title('Rectified left/right image');

% rectified anaglyph
% disabled for now since rectified images do not have the same size
% imshow(stereoAnaglyph(img1_rectified, img2_rectified));

% compute disparities
% img_width = size(img_left, 2);
% disparity_range = analyze_disparities(matched_pts1, matched_pts2, inliers, img_width);
% fprintf('\t Disparity range: %f\n', disparity_range);


