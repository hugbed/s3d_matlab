close all;
clear variables;

% load dataset images
dataset_name = 'Yard';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[F_truth, ~, ~, pts_L, pts_R, ~, ~] = load_dataset_outputs(dataset_name);

% estimate fundamental matrix parameters and eliminate outliers
[F, params, ~, ~] = solve_fundamental_matrix(pts_L', pts_R');

figure;

% estimation
subplot(2, 1, 1);
show_epilines(img_L, img_R, F, pts_L, pts_R);
title('Epipolar Lines Estimation (Left/Right)');

% ground truth
subplot(2, 1, 2);
show_epilines(img_L, img_R, F_truth, pts_L, pts_R);
title('Epipolar Lines Ground Truth (Left/Right)');
