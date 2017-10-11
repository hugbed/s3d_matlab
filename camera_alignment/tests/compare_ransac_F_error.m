close all;
clear variables;

% load dataset images
dataset_name = 'Drive';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[F_truth, ~, ~, pts_L, pts_R, ~, ~] = load_dataset_outputs(dataset_name);

% compute fundamental matrix
[F, alignment, inliers] = estimate_rig_fundamental_matrix(pts_L, pts_R, size(img_L));

% fundamental matrix errors

[Ef_mean, Ef_std] = fundamental_matrix_errors(pts_L, F, pts_R);

fprintf('Fundamental matrix error (should be 0):\n');
fprintf(' Ef (mean) = %f\n', Ef_mean);
fprintf(' Ef (std) = %f\n', Ef_std);