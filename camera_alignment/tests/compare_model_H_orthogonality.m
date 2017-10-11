close all;
clear variables;

% load dataset images
dataset_name = 'Drive';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[F_truth, ~, ~, pts_L, pts_R, ~, ~] = load_dataset_outputs(dataset_name);

% compute rectification
[F, alignment] = solve_fundamental_matrix(pts_L', pts_R');
[H, Hp] = compute_rectification(alignment);

% rectify images
img1_rectified = rectify(img_L, H);
img2_rectified = rectify(img_R, Hp);

% orthogonality
[h1, w1] = size(img_L);
[h2, w2] = size(img_R);
Eo_H1 = rad2deg(rectification_orthogonality(h1, w1, H));
Eo_H2 = rad2deg(rectification_orthogonality(h2, w2, Hp));

figure;
subplot(1, 2, 1); show_orthogonality(h1, w1, H); axis square;
subplot(1, 2, 2); show_orthogonality(h2, w2, Hp); axis square;

fprintf('Orthogonality (should be 90 degrees):\n');
fprintf(' Eo (H1) = %f\n', Eo_H1);
fprintf(' Eo (H2) = %f\n', Eo_H2);
