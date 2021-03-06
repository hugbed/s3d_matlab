% close all;
clear variables;

% load dataset images
dataset_name = 'Roof';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[F_truth, H_truth, Hp_truth, pts_L, pts_R, ~, ~] = load_dataset_outputs(dataset_name);

% estimate fundamental matrix parameters and eliminate outliers
[F, alignment, inliers, T] = estimate_fundamental_matrix(pts_L, pts_R, 'Method', 'STAN', ...
                                                         'Centered', 'true', 'ImgSize', size(img_L));
[H, Hp] = compute_rectification(alignment, T);

% compute rectification error
[Er_mean, Er_std] = rectification_error(pts_L, pts_R, H, Hp);
[Er_mean_truth, Er_std_truth] = rectification_error(pts_L, pts_R, H_truth, Hp_truth);

fprintf('Rectification error (vertical disparity remaining):\n');
fprintf(' Er (mean) = %f\n', Er_mean);
fprintf(' Er (std) = %f\n', Er_std);
fprintf(' Er (mean), Ground Truth = %f\n', Er_mean_truth);
fprintf(' Er (std), Ground Truth = %f\n', Er_std_truth);

% draw epilines on image
[img_L_epilines, img_R_epilines] = draw_epilines(img_L, img_R, F, pts_L, pts_R);

% same for ground truth
[img_L_epilines_truth, img_R_epilines_truth] = draw_epilines(img_L, img_R, F_truth, pts_L, pts_R);

% rectify images with epilines
img_L_rect = rectify(img_L_epilines, H);
img_R_rect = rectify(img_R_epilines, Hp);
img_L_rect_truth = rectify(img_L_epilines_truth, H_truth);
img_R_rect_truth = rectify(img_R_epilines_truth, Hp_truth);

% display epilines before rectification
figure;

subplot(2, 1, 1);
imshow(horzcat(img_L_rect, img_R_rect));
title('Epilines After Rectification');

subplot(2, 1, 2);
imshow(horzcat(img_L_rect_truth, img_R_rect_truth));
title('Epilines After Rectification (Ground Truth)');

