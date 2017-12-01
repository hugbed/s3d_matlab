function [ F, pts_L, pts_R, pts_L_noise, pts_R_noise, img_size ] = generate_virtual_dataset(baseline, t, a, noise_std)

nb_pts = 200;

% camera instrinsic matrix
width = 512;
height = width;
f = 703;
field_of_view_deg = 2 * rad2deg(atan(height/2/f));
aspect_ratio = 1.5; % it is assumed it is 1.0

C = [f, 0.0,              width / 2;
     0, aspect_ratio * f, height / 2;
     0, 0.0,              1.0] / f;

% right camera transform
% t = [0.3, 0.15, 0.0]';
% a = [0.0, 0.0, 0.0]';

% use real angles here! else F will be wrong
R = [1.0, -a(3), a(2);
     a(3), 1.0, -a(1);
    -a(2), a(1), 1];

% % translate baseline, then apply [R|t]
% H = eye(4);
% H(1:3, 1:3) = R;
% H(1:3, 4) = t;
% 
% T = eye(4);
% T(1:4, 4) = [t' 0]' + inv(H)*[-baseline, 0, 0, 1]';
% 
% H = T*H;
% 
% final R and t
% R = H(1:3, 1:3);
% t = H(1:3, 4);
F = camera_to_fundamental_matrix(C, C, R, t);
F = F / F(3, 2);

rank_F = rank(F)
det_F = det(F)

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

sampson_distance_F = sampson_distance(x, F, xp')

% create noisy points with std = noise_std
x_noise = x;
xp_noise = xp;
x_noise(1:2, :) = x(1:2, :) + sqrt(noise_std)*randn(nb_pts, 2)';
xp_noise(1:2, :) = xp(1:2, :) + sqrt(noise_std)*randn(nb_pts, 2)';

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
disparity_min = 4;
disparity_max = 30;
pts_disparity = xp - x;
good = disparity_min <= -pts_disparity(1, :) & -pts_disparity(1, :) <= disparity_max;
x = x(:, good);
xp = xp(:, good);
x_noise = x_noise(:, good);
xp_noise = xp_noise(:, good);
X_kept = X_kept(good, :);

% display relative transform
figure;
display_transform([1, 0, 0; 0, 1, 0; 0, 0, 1], [0, 0, 0]');
display_transform(R, t);

% and points
% scatter3(X(:, 1), X(:, 2), X(:, 3)); hold on;
figure;
display_transform([1, 0, 0; 0, 1, 0; 0, 0, 1], [0, 0, 0]');
display_transform(R, t);
scatter3(X_kept(:, 1), X_kept(:, 2), X_kept(:, 3)); hold off;

% figure;
% white_img = 255 * ones(height, width, 'uint8');
% showMatchedFeatures(white_img, white_img, x', xp');

pts_L = x(1:2, :)';
pts_R = xp(1:2, :)';
pts_L_noise = x_noise(1:2, :)';
pts_R_noise = xp_noise(1:2, :)';
img_size = [height, width];

end
