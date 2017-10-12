clear variables;

% load dataset images
dataset_name = 'Drive';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[F_truth, ~, ~, pts_L, pts_R, ~, ~] = load_dataset_outputs(dataset_name);

% center points
[pts_L, pts_R] = center_pts(pts_L, pts_R, size(img_L));

% compute fundamental matrix
[F, alignment] = solve_fundamental_matrix(pts_L', pts_R');

% fundamental matrix errors
[Ef_mean, Ef_std] = fundamental_matrix_errors(pts_L, F, pts_R);
[Ef_mean_truth, Ef_std_truth] = fundamental_matrix_errors(pts_L, F_truth, pts_R);

% ground truth

fprintf('Fundamental matrix error (should be 0):\n');
fprintf(' Ef (mean) = %f\n', Ef_mean);
fprintf(' Ef (std) = %f\n', Ef_std);
fprintf(' Ef (mean), Ground Truth = %f\n', Ef_mean_truth);
fprintf(' Ef (std), Ground Truth  = %f\n', Ef_std_truth);