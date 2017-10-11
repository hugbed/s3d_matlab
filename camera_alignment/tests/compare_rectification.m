close all;
clear variables;

% load dataset images
dataset_name = 'Arch';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[F_truth, H1_L, H2_R, pts_L, pts_R, img_L_rect_truth, img_R_rect_truth] = load_dataset_outputs(dataset_name);

% rectify images from ground truth H
img_L_rectified = rectify(img_L, H1_L);
img_R_rectified = rectify(img_R, H2_R);

% alternative without black borders
% [img_L_rectified, img_R_rectified] = rectifyStereoImages(img_L, img_R, projective2d(H1_L'), projective2d(H2_R'));

% display rectified images
figure;
subplot(2, 1, 1);
imshow(horzcat(img_L_rectified, img_R_rectified));
title('Rectified Images from Ground Truth H1, H2');

% display ground truth
subplot(2, 1, 2);
imshow(horzcat(img_L_rect_truth, img_R_rect_truth));
title('Rectified Ground Truth Images');

