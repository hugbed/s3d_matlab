close all;
clear variables;

% load dataset
t = [0.1, 0.0, 0.0]';
a = [0.1, 0.0, 0.1]'; % roll, pitch, tilt; (ZYX)
nb_pts = 200;
noise_std = 1;
percent_outliers = 0.2;
nb_outliers = floor(percent_outliers*nb_pts);
[F_gold, pts_L, pts_R, pts_L_noise, pts_R_noise, X, img_size] = generate_virtual_dataset(0.5, t, a, nb_pts, noise_std, percent_outliers);
white_img = 255 * ones(img_size(1), img_size(2), 'uint8');
img_L = white_img;
img_R = white_img;

% ground truth
figure;
showMatchedFeatures(img_L, img_R, pts_L_noise, pts_R_noise);
title('Noisy Feature Points Matches');

figure;
subplot(2, 2, 1);
showMatchedFeatures(img_L, img_R, pts_L_noise(nb_outliers+1:end, :), pts_R_noise(nb_outliers+1:end, :));
title('Inliers');

subplot(2, 2, 2);
showMatchedFeatures(img_L, img_R, pts_L_noise(1:nb_outliers, :), pts_R_noise(1:nb_outliers, :));
title('Outliers');

% estimate fundamental matrix parameters from noisy points and eliminate outliers
[F, alignment, inliers, T] = estimate_fundamental_matrix(pts_L_noise, pts_R_noise, 'Method', 'LMedS', ...
                                                         'Centered', 'true', 'ImgSize', size(img_L));

% uncaught outliers
nb_uncaught_outliers = sum(inliers(1:nb_outliers))
                                                     
% filter outliers
pts_L_inliers = pts_L(inliers, :);
pts_R_inliers = pts_R(inliers, :);

subplot(2, 2, 3);
showMatchedFeatures(img_L, img_R, pts_L_noise(inliers, :), pts_R_noise(inliers, :));
title('Filtered Inliers (robust method)');

subplot(2, 2, 4);
showMatchedFeatures(img_L, img_R, pts_L_noise(~inliers, :), pts_R_noise(~inliers, :));
title('Filtered Outliers (robust method)');

% display inliers/outliers 3d points
figure;
scatter3(X(inliers, 1), X(inliers, 2), X(inliers, 3)); hold on;
scatter3(X(~inliers, 1), X(~inliers, 2), X(~inliers, 3)); hold off;
                                                     
% draw epilines on image (with points without noise chosen as inliers)
[img_L_epilines, img_R_epilines] = draw_epilines(img_L, img_R, F, pts_L_inliers, pts_R_inliers);
[img_L_epilines_gold, img_R_epilines_gold] = draw_epilines(img_L, img_R, F_gold, pts_L_inliers, pts_R_inliers);

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
