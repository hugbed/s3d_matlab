close all;
clear variables;

% load dataset images
dataset_name = 'Arch';
[img_L, img_R] = load_dataset_inputs(dataset_name);

% load dataset feature points
[~, ~, ~, pts_L, pts_R, ~, ~] = load_dataset_outputs(dataset_name);

% find feature matches
[matched_pts1, matched_pts2] = find_matches(img_L, img_R);

% display proposed/computed matches
figure;

subplot(2, 1, 1);
showMatchedFeatures(img_L, img_R, pts_L, pts_R, 'montage');
title('Suggested feature points');

subplot(2, 1, 2);
showMatchedFeatures(img_L, img_R, matched_pts1, matched_pts2, 'montage');
title('Putatively Matched Points (Including Outliers)');