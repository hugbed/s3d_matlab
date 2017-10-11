close all;
clear variables;

% load dataset images
dataset_name = 'Slate';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[F_truth, H_truth, Hp_truth, pts_L, pts_R, ~, ~] = load_dataset_outputs(dataset_name);

% should they not be transposed in load_dataset_outputs?
H_truth = H_truth'; % for some reasons... (to give the correct results)
Hp_truth = Hp_truth'; % for some reasons... (to give the correct results)

% compute rectification
[F, alignment] = solve_fundamental_matrix(pts_L', pts_R');
[H, Hp] = compute_rectification(alignment);

% rectify images
img1_rectified = rectify(img_L, H);
img2_rectified = rectify(img_R, Hp);

% orthogonality
[h1, w1] = size(img_L);
[h2, w2] = size(img_R);
Eo_H = rad2deg(rectification_orthogonality(h1, w1, H));
Eo_Hp = rad2deg(rectification_orthogonality(h2, w2, Hp));
Eo_H_truth = rad2deg(rectification_orthogonality(h1, w1, H_truth));
Eo_Hp_truth = rad2deg(rectification_orthogonality(h2, w2, Hp_truth));

% aspect ratio
Ea_H = rectification_aspect_ratio(h1, w1, H);
Ea_Hp = rectification_aspect_ratio(h2, w2, Hp);
Ea_H_truth = rectification_aspect_ratio(h1, w1, H_truth);
Ea_Hp_truth = rectification_aspect_ratio(h2, w2, Hp_truth);

% display results
figure;
subplot(2, 2, 1); show_rectification_orthogonality(h1, w1, H); axis square; axis ij;
title('Image Border Centers Rectification (Left)');
subplot(2, 2, 2); show_rectification_orthogonality(h2, w2, Hp); axis square; axis ij;
title('Image Border Centers Rectification (Right)');

subplot(2, 2, 3); show_rectification_orthogonality(h1, w1, H_truth); axis square; axis ij;
title('Image Border Centers Rectification (Ground Truth Left)');
subplot(2, 2, 4); show_rectification_orthogonality(h2, w2, Hp_truth); axis square; axis ij;
title('Image Border Centers Rectification (Ground Truth Right)');

figure;
subplot(2, 2, 1); show_rectification_aspect_ratio(h1, w1, H); axis square; axis ij;
title('Image Corners After Rectification (Left)');
subplot(2, 2, 2); show_rectification_aspect_ratio(h2, w2, Hp); axis square; axis ij;
title('Image Corners After Rectification (Right)');

subplot(2, 2, 3); show_rectification_aspect_ratio(h1, w1, H_truth); axis square; axis ij;
title('Image Corners After Rectification (Ground Truth Left)');
subplot(2, 2, 4); show_rectification_aspect_ratio(h2, w2, Hp_truth); axis square; axis ij;
title('Image Corners After Rectification (Ground Truth Right)');

fprintf('Orthogonality (should be 90 degrees):\n');
fprintf(' Eo (H1) = %f\n', Eo_H);
fprintf(' Eo (H2) = %f\n', Eo_Hp);
fprintf(' Eo, Ground Truth (H1) = %f\n', Eo_H_truth);
fprintf(' Eo, Ground Truth (H2) = %f\n', Eo_Hp_truth);
fprintf('Aspect Ratio (should be 1.0):\n');
fprintf(' Ea (H1) = %f\n', Ea_H);
fprintf(' Ea (H2) = %f\n', Ea_Hp);
fprintf(' Ea, Ground Truth (H1) = %f\n', Ea_H_truth);
fprintf(' Ea, Ground Truth (H2) = %f\n', Ea_Hp_truth);
