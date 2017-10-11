close all;
clear variables;

% load dataset images
dataset_name = 'Arch';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[F_truth, H_truth, Hp_truth, pts_L, pts_R, ~, ~] = load_dataset_outputs(dataset_name);

% estimate fundamental matrix parameters and eliminate outliers
[F, alignment] = solve_fundamental_matrix(pts_L', pts_R');
[H, Hp] = compute_rectification(alignment);

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

subplot(3, 1, 1);
imshow(horzcat(img_L_epilines, img_R_epilines));
title('Epilines Before Rectification');

subplot(3, 1, 2);
imshow(horzcat(img_L_rect, img_R_rect));
title('Epilines After Rectification');

subplot(3, 1, 3);
imshow(horzcat(img_L_rect_truth, img_R_rect_truth));
title('Epilines After Rectification (Ground Truth)');
