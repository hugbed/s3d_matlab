close all;
clear variables;

% load dataset images
dataset_name = 'Arch';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[F_truth, H_truth, Hp_truth, pts_L, pts_R, img_L_rect_truth, img_R_rect_truth] = load_dataset_outputs(dataset_name);

% compute rectification
[F, alignment] = solve_fundamental_matrix(pts_L', pts_R');
[H, Hp] = compute_rectification(alignment);

% compute rectification error
[Er_mean, Er_std] = rectification_error(pts_L, pts_R, H', Hp');
[Er_mean_truth, Er_std_truth] = rectification_error(pts_L, pts_R, H_truth', Hp_truth');

fprintf('Rectification error (vertical disparity remaining):\n');
fprintf(' Er (mean) = %f\n', Er_mean);
fprintf(' Er (std) = %f\n', Er_std);
fprintf(' Er (mean), Ground Truth = %f\n', Er_mean_truth);
fprintf(' Er (std), Ground Truth = %f\n', Er_std_truth);

% rectify images
% [img_L_rectified, img_R_rectified] = rectifyStereoImages(img_L, img_R, projective2d(H), projective2d(Hp));
img_L_rectified = rectify(img_L, H);
img_R_rectified = rectify(img_R, Hp);

% display rectified images
figure;
subplot(2, 1, 1);
imshow(horzcat(img_L_rectified, img_R_rectified));
title('Rectified Image (From Model)');

subplot(2, 1, 2);
imshow(horzcat(img_L_rect_truth, img_R_rect_truth));
title('Rectified Images (Ground Truth)');
