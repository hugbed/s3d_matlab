close all;
clear variables;

% load dataset images
dataset_name = 'Slate';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[pts_L_SURF, pts_R_SURF] = find_matches(img_L, img_R);
pts_L = pts_L_SURF.Location;
pts_R = pts_R_SURF.Location;

% matches with outliers
showMatchedFeatures(img_L, img_R, pts_L, pts_R, 'montage');
title('Putatively Matched Points (Including Outliers)');

% estimate fundamental matrix parameters and eliminate outliers
[F, alignment, inliers, T] = estimate_fundamental_matrix(pts_L, pts_R, 'Method', 'LMedS', ...
                                                         'Centered', 'true', 'ImgSize', size(img_L));

% matches without outliers
showMatchedFeatures(img_L, img_R, pts_L(inliers, :), pts_R(inliers, :), 'montage');
title('Putatively Matched Points (Without Outliers)');
                                                     
% draw epilines on image
[img_L_epilines, img_R_epilines] = draw_epilines(img_L, img_R, F, pts_L(inliers, :), pts_R(inliers, :));

% rectify images with epilines
[H, Hp] = compute_rectification(alignment, T);
img_L_rect = rectify(img_L_epilines, H);
img_R_rect = rectify(img_R_epilines, Hp);

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