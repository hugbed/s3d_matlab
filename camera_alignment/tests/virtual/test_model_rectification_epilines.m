close all;

% load dataset
t = [0.0, 0.1,-0.0]';
a = [0.0, 0.0,  0.0]'; % tilt, pitch, roll
[C, R, t, pts_L, pts_R, img_size] = generate_virtual_dataset(1, t, a);
white_img = 255 * ones(img_size(1), img_size(2), 'uint8');
img_L = white_img;
img_R = white_img;

% ground truth
figure;
showMatchedFeatures(img_L, img_R, pts_L, pts_R);
title('Suggested Feature Points (Ground Truth)');

% center pts
T = [1, 0, -img_size(1)/2;
     0, 1, -img_size(2)/2;
     0, 0,  1];

N = size(pts_L, 1);
pts_L_H = (T*[pts_L ones(N, 1)]')';
pts_R_H = (T*[pts_R ones(N, 1)]')';
pts_L_centered = pts_L_H(:, 1:2);
pts_R_centered = pts_R_H(:, 1:2);
 
% estimate fundamental matrix parameters and eliminate outliers
[F, alignment] = solve_fundamental_matrix(pts_L_centered', pts_R_centered');

% decenter F
F = T'*F*T;
F = F / F(3, 2);

% draw epilines on image
[img_L_epilines, img_R_epilines] = draw_epilines(img_L, img_R, F, pts_L, pts_R);

% rectify images with epilines
[img_L_rect, img_R_rect] = rectify_alignment(img_L_epilines, img_R_epilines, alignment);

% [H, Hp] = compute_rectification(alignment);
% [H1, H2] = estimateUncalibratedRectification(F, pts_L, pts_R, size(img_L))
% [img_L_rect, img_R_rect] = rectifyStereoImages(img_L_epilines, img_R_epilines, H, Hp);

% display epilines before rectification
figure;
subplot(2, 1, 1); imshow(horzcat(img_L_epilines, img_R_epilines)); title('Epilines Before Rectification');
subplot(2, 1, 2); imshow(horzcat(img_L_rect, img_R_rect)); title('Epilines After Rectification');
 
fprintf('Results:\n');
fprintf(' vertical (degrees) = %f\n', alignment(1) * 180 / pi);
fprintf(' roll (degrees) = %f\n', alignment(2) * 180 / pi);
fprintf(' zoom (percent) = %f\n', (alignment(3) + 1.0) * 100.0);
fprintf(' tiltOffset (pixels) = %f\n', alignment(4));
fprintf(' tiltKeystone (radians / m) = %f\n', alignment(5));
fprintf(' panKeystone (radians / m) = %f\n', alignment(6));
fprintf(' zParallaxDeformation (m/m) = %f\n', alignment(7));

% load rgb images
% dir = strcat('dataset/data/', dataset_name);
% img_L_RGB = imread(strcat(dir, '/', dataset_name, '_L.bmp'));
% img_R_RGB = imread(strcat(dir, '/', dataset_name, '_R.bmp'));
% 
% [H1, H2] = compute_rectification(alignment);

% name = 'ArchMatlab';
% save_dataset(name, img_L_RGB, img_R_RGB, pts_L, pts_R, F, H1, H2, img_L_rect, img_R_rect);
