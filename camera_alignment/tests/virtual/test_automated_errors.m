close all;
clear variables;

all_distances = zeros(1, 200);
i = 1;

for i = 1:100

% load dataset
t = [0.1, 0.0, 0.0]';
a = [0.0, 0.0, 0.0]'; % roll, pitch, tilt; (ZYX)
noise_std = 1;
percent_outliers = 0.05;
[F_gold, pts_L, pts_R, pts_L_noise, pts_R_noise, img_size] = generate_virtual_dataset(0.5, t, a, noise_std, percent_outliers);

% estimate fundamental matrix parameters from noisy points and eliminate outliers
[F, alignment, inliers, T] = estimate_fundamental_matrix(pts_L_noise, pts_R_noise, 'Method', 'LMedS', ...
                                                         'Centered', 'true', 'ImgSize', img_size);
                                                    
% filter outliers
pts_L_inliers = pts_L(inliers, :);
pts_R_inliers = pts_R(inliers, :);

% compute errors of the estimated geometry from noisy points to perfect points
pts_L_H = pts_L;
pts_R_H = pts_R;
pts_L_H(:, 3) = 1;
pts_R_H(:, 3)= 1;
distances = sampson_distance(pts_L_H', F, pts_R_H);
distances_gold = sampson_distance(pts_L_H', F_gold, pts_R_H);

all_distances(i, :) = distances;

end

all_distances_mean = mean(all_distances, 2);
all_distances_std = std(all_distances');

fprintf('\nSampson Errors:\n');
fprintf(' Estimation (mean) = %f\n', mean(all_distances_mean));
fprintf(' Estimation (std) = %f\n', mean(all_distances_std));
