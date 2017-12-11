function [ F, pts_L, pts_R, pts_L_noise, pts_R_noise, X_kept, img_size ] = ...
    generate_virtual_dataset(baseline, t, a, nb_pts_kept, noise_std, percent_outliers)

nb_pts = 2*nb_pts_kept;

% camera instrinsic matrix
width = 512;
height = width;
f = 703;
field_of_view_deg = 2 * rad2deg(atan(height/2/f));
aspect_ratio = 1.5; % it is assumed it is 1.0

C = [f, 0.0,              width / 2;
     0, aspect_ratio * f, height / 2;
     0, 0.0,              1.0] / f;

% estimation (leads to error in F since it uses small angle approximation)
% R = [1.0, -a(3), a(2);
%      a(3), 1.0, -a(1);
%     -a(2), a(1), 1];

% real rotation (good F)
R = eul2rotm(a');
t = -R*t; % translate before rotation to simplify manual translation

F = camera_to_fundamental_matrix(C, C, R, t);
F = F / F(3, 2);

% projection matrices
P1 = C*eye(3, 4);
P2 = C*[R t];

% generate points from restricted field of view
pts_fov = floor(field_of_view_deg * 0.80);
precision = 1000;
axis_x = randperm(pts_fov * precision, nb_pts)/precision - pts_fov/2;
axis_y = randperm(pts_fov * precision, nb_pts)/precision - pts_fov/2;
depth = randperm(30 * precision, nb_pts)/precision + 0.5;

x_values = depth .* tan(deg2rad(axis_y));
y_values = depth .* tan(deg2rad(axis_x));
z_values = depth;

X = [x_values' y_values', z_values', ones(nb_pts, 1)];

% project points in both cameras
x = P1*X';
x = x ./ x(3, :);
xp = P2*X';
xp = xp ./ xp(3, :);

% create noisy points with std = noise_std
x_noise = x;
xp_noise = xp;
x_noise(1:2, :) = x(1:2, :) + noise_std*randn(nb_pts, 2)';
xp_noise(1:2, :) = xp(1:2, :) + noise_std*randn(nb_pts, 2)';

% filter points
X_kept = X;

% filter x oustide image
good = x_noise < width & x_noise < height & x_noise >= 0;
good = good(1, :) & good(2, :);
x = x(:, good);
xp = xp(:, good);
x_noise = x_noise(:, good);
xp_noise = xp_noise(:, good);
X_kept = X_kept(good, :);

% filter xp outside image
good = xp_noise < width & xp_noise < height & xp_noise >= 0;
good = good(1, :) & good(2, :);
x = x(:, good);
xp = xp(:, good);
x_noise = x_noise(:, good);
xp_noise = xp_noise(:, good);
X_kept = X_kept(good, :);

% filter disparity outside range
% disparity_min = 4;
% disparity_max = 30;
% pts_disparity = xp - x;
% good = disparity_min <= pts_disparity(1, :) & pts_disparity(1, :) <= disparity_max;
% x = x(:, good);
% xp = xp(:, good);
% x_noise = x_noise(:, good);
% xp_noise = xp_noise(:, good);
% X_kept = X_kept(good, :);

% display relative transform
% figure;
% display_transform([1, 0, 0; 0, 1, 0; 0, 0, 1], [0, 0, 0]');
% display_transform(R, t);
% 
% % and points
% % scatter3(X(:, 1), X(:, 2), X(:, 3)); hold on;
% figure;
% display_transform([1, 0, 0; 0, 1, 0; 0, 0, 1], [0, 0, 0]');
% display_transform(R, t);
% scatter3(X_kept(:, 1), X_kept(:, 2), X_kept(:, 3)); hold off;

% figure;
% white_img = 255 * ones(height, width, 'uint8');
% showMatchedFeatures(white_img, white_img, x', xp');

% add outliers
outlier_distance_treshold = 40;
nb_outliers = percent_outliers*nb_pts_kept;

for i = 1:nb_outliers
    outlier_noise = 2*outlier_distance_treshold*rand(2,1) - outlier_distance_treshold;
    xp_noise(1:2, i) = x(1:2, i) + outlier_noise;    
end

% remove homogenous dimension and keep nb_pts_kept
x = x(1:2, 1:nb_pts_kept);
xp = xp(1:2, 1:nb_pts_kept);
x_noise = x_noise(1:2, 1:nb_pts_kept);
xp_noise = xp_noise(1:2, 1:nb_pts_kept);

pts_L = x';
pts_R = xp';
pts_L_noise = x_noise';
pts_R_noise = xp_noise';
img_size = [height, width];

end
