close all;
clear variables;

% load dataset images
dataset_name = 'Arch';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[F_truth, ~, ~, pts_L, pts_R, ~, ~] = load_dataset_outputs(dataset_name);

% estimate fundamental matrix parameters and eliminate outliers
[F, params, inliers] = estimate_rig_fundamental_matrix(pts_L, pts_R, size(img_L));

figure;

% estimation
subplot(2, 1, 1);
show_epilines(img_L, img_R, F, pts_L(inliers, :), pts_R(inliers, :));
title('Epipolar Lines Estimation (Left/Right)');

% ground truth
subplot(2, 1, 2);
show_epilines(img_L, img_R, F_truth', pts_L(inliers, :), pts_R(inliers, :));
title('Epipolar Lines Ground Truth (Left/Right)');