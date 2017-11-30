clear variables;

% load dataset images
dataset_name = 'Drive';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[F_truth, ~, ~, pts_L, pts_R, ~, ~] = load_dataset_outputs(dataset_name);

% compute fundamental matrix
[F, alignment] = estimate_fundamental_matrix(pts_L, pts_R, 'Method', 'STAN', ...
                                             'Centered', 'true', 'ImgSize', size(img_L));

% fundamental matrix errors
[Ef_mean, Ef_std] = fundamental_matrix_errors(pts_L, F, pts_R);
[Ef_mean_truth, Ef_std_truth] = fundamental_matrix_errors(pts_L, F_truth, pts_R);

% sampson distance
[N, ~] = size(pts_L);
pts_L_H = [pts_L ones(N, 1)];
pts_R_H = [pts_R ones(N, 1)];
sampson_d = sampson_distance(pts_L_H', F, pts_R_H);
sampson_d_truth = sampson_distance(pts_L_H', F_truth, pts_R_H);

% compare errors with ground truth
fprintf('Fundamental matrix error (should be 0):\n');
fprintf(' Ef (mean) = %f\n', Ef_mean);
fprintf(' Ef (std) = %f\n', Ef_std);
fprintf(' Ef (mean), Ground Truth = %f\n', Ef_mean_truth);
fprintf(' Ef (std), Ground Truth  = %f\n', Ef_std_truth);
fprintf(' Sampson Dist (mean) = %f\n', mean(sampson_d));
fprintf(' Sampson Dist (std) = %f\n', std(sampson_d));
fprintf(' Sampson Dist (mean), Ground Truth = %f\n', mean(sampson_d_truth));
fprintf(' Sampson Dist (std), Ground Truth = %f\n', std(sampson_d_truth));