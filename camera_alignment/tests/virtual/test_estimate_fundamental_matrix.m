close all;
clear variables;

% load dataset
t = [-0.2, 0.0, 0.0]';
a = [0.0, 0.0, 0.01]'; % tilt, pitch, roll
noise_std = 0;
[F_gold, pts_L, pts_R, pts_L_noise, pts_R_noise, img_size] = generate_virtual_dataset(0.5, t, a, noise_std);
white_img = 255 * ones(img_size(1), img_size(2), 'uint8');
img_L = white_img;
img_R = white_img;

% ground truth
figure;
showMatchedFeatures(img_L, img_R, pts_L_noise, pts_R_noise);
title('Suggested Feature Points (Ground Truth)');

% estimate fundamental matrix parameters from noisy points and eliminate outliers
[F, alignment, inliers, T] = estimate_fundamental_matrix(pts_L_noise, pts_R_noise, 'Method', 'STAN', ...
                                                         'Centered', 'true', 'ImgSize', size(img_L));

% draw epilines on image (with points without noise)
[img_L_epilines, img_R_epilines] = draw_epilines(img_L, img_R, F, pts_L, pts_R);
[img_L_epilines_gold, img_R_epilines_gold] = draw_epilines(img_L, img_R, F_gold, pts_L, pts_R);

% rectify images with epilines
[H, Hp] = compute_rectification(alignment, T);
img_L_rect = rectify(img_L_epilines, H);
img_R_rect = rectify(img_R_epilines, Hp);
img_L_rect_gold = rectify(img_L_epilines_gold, H);
img_R_rect_gold = rectify(img_R_epilines_gold, Hp);

% display epilines before rectification
figure;
subplot(2, 1, 1); imshow(horzcat(img_L_epilines, img_R_epilines)); title('Epilines Before Rectification');
subplot(2, 1, 2); imshow(horzcat(img_L_rect, img_R_rect)); title('Epilines After Rectification');

figure;
subplot(2, 1, 1); imshow(horzcat(img_L_epilines_gold, img_R_epilines_gold)); title('Epilines Before Rectification (Gold F)');
subplot(2, 1, 2); imshow(horzcat(img_L_rect_gold, img_R_rect_gold)); title('Epilines After Rectification (Gold F)');
 
fprintf('Results:\n');
fprintf(' vertical (degrees) = %f\n', alignment(1) * 180 / pi);
fprintf(' roll (degrees) = %f\n', alignment(2) * 180 / pi);
fprintf(' zoom (percent) = %f\n', (alignment(3) + 1.0) * 100.0);
fprintf(' tiltOffset (pixels) = %f\n', alignment(4));
fprintf(' tiltKeystone (radians / m) = %f\n', alignment(5));
fprintf(' panKeystone (radians / m) = %f\n', alignment(6));
fprintf(' zParallaxDeformation (m/m) = %f\n', alignment(7));

% compute errors of the estimated geometry from noisy points to perfect points
pts_L_H = pts_L;
pts_R_H = pts_R;
pts_L_H(:, 3) = 1;
pts_R_H(:, 3)= 1;
distances = sampson_distance(pts_L_H', F, pts_R_H);
distances_gold = sampson_distance(pts_L_H', F_gold, pts_R_H);

fprintf('\nSampson Errors:\n');
fprintf(' Estimation (mean) = %f\n', mean(distances));
fprintf(' Estimation (std) = %f\n', std(distances));
fprintf(' Gold (mean) = %f\n', mean(distances_gold));
fprintf(' Gold (std) = %f\n', std(distances_gold));
