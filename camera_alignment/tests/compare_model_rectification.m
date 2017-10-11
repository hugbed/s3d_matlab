% close all;
clear variables;

% load dataset images
dataset_name = 'Lab';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[F_truth, H_truth, Hp_truth, pts_L, pts_R, img_L_rect_truth, img_R_rect_truth] = load_dataset_outputs(dataset_name);

% compute rectification
[F, alignment] = solve_fundamental_matrix(pts_L', pts_R');
[H, Hp] = compute_rectification(alignment)

% compute rectification error
[Er_mean, Er_std] = rectification_error(pts_L, pts_R, H, Hp);

fprintf('Rectification error (vertical disparity remaining):\n');
fprintf(' Er (mean) = %f\n', Er_mean);
fprintf(' Er (std) = %f\n', Er_std);

% rectify images
% [img_L_rectified, img_R_rectified] = rectifyStereoImages(img_L, img_R, projective2d(H), projective2d(Hp));
img_L_rectified = rectify(img_L, H);
img_R_rectified = rectify(img_R, Hp);

% display rectified images
figure;
subplot(2, 2, 1);
imshow(img_L_rectified);
title('Rectified Left Image');

subplot(2, 2, 2);
imshow(img_R_rectified);
title('Rectified Right Image');

subplot(2, 2, 3);
imshow(img_L_rect_truth);
title('Rectified Left Image (Ground Truth)');

subplot(2, 2, 4);
imshow(img_R_rect_truth);
title('Rectified Right Image (Ground Truth)');