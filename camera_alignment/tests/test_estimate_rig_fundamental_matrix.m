close all;

% load dataset images
dataset_name = 'Arch';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[~, ~, ~, ~, ~, ~, ~] = load_dataset_outputs(dataset_name);

% find feature matches
[matched_pts1, matched_pts2] = find_matches(img_L, img_R);

% display matches
figure;
subplot(2, 1, 1);
showMatchedFeatures(img_L, img_R, matched_pts1, matched_pts2);
title('Putatively Matched Points (Including Outliers)');

% estimate fundamental matrix parameters and eliminate outliers
[F, alignment, inliers] = estimate_rig_fundamental_matrix(matched_pts1.Location, matched_pts2.Location, size(img_L));

% [F, inliers] = estimateFundamentalMatrix(matched_pts1, matched_pts2, 'Method', 'RANSAC', 'NumTrials', 2000);
pts_L_inliers = matched_pts1.Location(inliers, :);
pts_R_inliers = matched_pts2.Location(inliers, :);
[NB_INLIERS, ~] = size(pts_L_inliers);

% [T1,T2] = estimateUncalibratedRectification(F,matched_pts1(inliers),matched_pts2(inliers), size(img_L))
[H1, H2] = compute_rectification(alignment);

% display matches (inliers)
subplot(2, 1, 2);
showMatchedFeatures(img_L, img_R, pts_L_inliers, pts_R_inliers);
title('Point Matches (Inliers)');

% display alignment
% fprintf('Results:\n');
% fprintf('\t vertical (degrees) = %f\n', alignment(1) * 180 / pi);
% fprintf('\t roll (degrees) = %f\n', alignment(2) * 180 / pi);
% fprintf('\t zoom (percent) = %f\n', (alignment(3) + 1.0) * 100.0);
% fprintf('\t tiltOffset (percent) = %f\n', alignment(4));
% fprintf('\t tiltKeystone (pixels) = %f\n', alignment(5));
% fprintf('\t panKeystone (radians / m) = %f\n', alignment(6));
% fprintf('\t zParallaxDeformation (m/m) = %f\n', alignment(7));

% draw epilines on image
[img_L_epilines, img_R_epilines] = draw_epilines(img_L, img_R, F, pts_L_inliers, pts_R_inliers);

% rectify images
[img_L_rectified, img_R_rectified] = rectify_alignment(img_L_epilines, img_R_epilines, alignment);
% [img_L_rectified, img_R_rectified] = rectifyStereoImages(img_L_epilines, img_R_epilines, projective2d(T1), projective2d(T2));

figure;
subplot(2, 1, 1); imshow(horzcat(img_L_epilines, img_R_epilines)); title('Epilines Before Rectification');
subplot(2, 1, 2); imshow(horzcat(img_L_rectified, img_R_rectified)); title('Epilines After Rectification');

% rectified anaglyph
% figure;
% imshow(stereoAnaglyph(img1_rectified, img2_rectified));

% compute disparities
% img_width = size(img_L, 2);
% disparity_range = analyze_disparities(matched_pts1, matched_pts2, inliers, img_width);
% fprintf('\t Disparity range: %f\n', disparity_range);

% fundamental matrix errors
[Ef_mean, Ef_std] = fundamental_matrix_errors(pts_L_inliers, F, pts_R_inliers);

% sampson distance
pts_L_H = [pts_L_inliers, ones(NB_INLIERS, 1)];
pts_R_H = [pts_R_inliers ones(NB_INLIERS, 1)];
sampson_d = sampson_distance(pts_L_H', F, pts_R_H);

fprintf('Fundamental matrix error (should be 0):\n');
fprintf(' Ef (mean) = %f\n', Ef_mean);
fprintf(' Ef (std) = %f\n', Ef_std);
fprintf(' Sampson Dist (mean) = %f\n', mean(sampson_d));
fprintf(' Sampson Dist (std) = %f\n', std(sampson_d));

% name = 'tree_frame';
% save_dataset(name, img_L_RGB, img_R_RGB, pts_L_inliers, pts_R_inliers, F, H1, H2, img_L_rectified, img_R_rectified);
