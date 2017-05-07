close all;

% load images
img_left = rgb2gray(imread('clip04-01-left.pbm'));
img_right = rgb2gray(imread('clip04-01-right.pbm'));

% img_left = imresize(img_left, 0.22);
% img_right = imresize(img_right, 0.22);

estimate_rig_fundamental_matrix(img_left, img_right);