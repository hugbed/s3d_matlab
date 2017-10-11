close all;
clear variables;

% load dataset images
dataset_name = 'Drive';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[~, ~, ~, pts_L, pts_R, ~, ~] = load_dataset_outputs(dataset_name);

% estimate fundamental matrix parameters and eliminate outliers
[f, params, inliers] = estimate_rig_fundamental_matrix(pts_L, pts_R, size(img_L));

% show all feature points
figure;
subplot(2, 1, 1);
showMatchedFeatures(img_L, ...
                    img_R, ...
                    pts_L, ...
                    pts_R, ...
                    'montage');
title('Putatively Matched Points (including Outliers)');

% show remaining inliers
subplot(2, 1, 2);
showMatchedFeatures(img_L, ...
                    img_R, ...
                    pts_L(inliers, :), ...
                    pts_R(inliers, :), ...
                    'montage','PlotOptions',{'ro','go','y--'});
title('Matched points after estimation (inliers only)');


