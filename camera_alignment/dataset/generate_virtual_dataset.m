function [ C, R, t, pts_L, pts_R, img_size ] = generate_virtual_dataset(baseline, t, a, noise_std)

nb_pts = 200;

% camera instrinsic matrix
width = 512;
height = width;
f = 703;
field_of_view_deg = 2 * rad2deg(atan(height/2/f));
aspect_ratio = 1.5; % it is assumed it is 1.0

C = [f, 0.0,              width / 2,  0.0;
     0, aspect_ratio * f, height / 2, 0.0;
     0, 0.0,              1.0,        0.0] / f;

% right camera transform
% t = [0.3, 0.15, 0.0]';
% a = [0.0, 0.0, 0.0]';

R = [1.0, -a(3), a(2);
     a(3), 1.0, -a(1);
    -a(2), a(1), 1];

% translate baseline, then apply [R|t]
H = eye(4);
H(1:3, 1:3) = R;
H(1:3, 4) = t;

T = eye(4);
T(1:4, 4) = [t' 1]' + inv(H)*[-baseline, 0, 0, 1]';

H = T*H;

% generate points from restricted field of view
pts_fov = floor(field_of_view_deg * 0.80);
precision = 1000;
axis_x = randperm(pts_fov * precision, nb_pts)/precision - pts_fov/2;
axis_y = randperm(pts_fov * precision, nb_pts)/precision - pts_fov/2;
depth = randperm(30 * precision, nb_pts)/precision + 1;

x_values = depth .* tan(deg2rad(axis_y));
y_values = depth .* tan(deg2rad(axis_x));
z_values = depth;

% project points in both cameras
X = [x_values' y_values', z_values', ones(nb_pts, 1)];

x = C*X';
x(1:2, :)  = x(1:2, :) ./ x(3, :);

xp = C*H*X';
xp(1:2, :)  = xp(1:2, :) ./ xp(3, :);

% add gaussian noise to image points
x_noise = sqrt(noise_std)*randn(nb_pts, 2);
xp_noise = sqrt(noise_std)*randn(nb_pts, 2);
x(1:2, :) = x(1:2, :) + x_noise';
xp(1:2, :) = xp(1:2, :) + xp_noise';

% filter x oustide image
good = x < width & x < height & x >= 0;
good = good(1, :) & good(2, :) & good(3, :);
x = x(:, good);
xp = xp(:, good);
X_kept = X(good, :);

% filter xp outside image
good = xp < width & xp < height & xp >= 0;
good = good(1, :) & good(2, :) & good(3, :);
x = x(:, good);
xp = xp(:, good);
X_kept = X(good, :);

% filter disparity outside range
% disparity_min = 0;
% disparity_max = 30;
% pts_disparity = xp - x;
% good = pts_disparity(1, :) >= disparity_min & pts_disparity(1, :) <= disparity_max;
% x = x(:, good);
% xp = xp(:, good);
% X_kept = X(good, :);

% display relative transform
figure;
display_transform([1, 0, 0; 0, 1, 0; 0, 0, 1], [0, 0, 0]');
display_transform([H(1,1),  H(1, 2), H(1, 3); ... 
                   H(2, 1), H(2, 2), H(2, 3); ...
                   H(3, 1), H(3,2),  H(3, 3)], [H(1, 4), H(2, 4), H(3, 4)]');

% and points
% scatter3(X(:, 1), X(:, 2), X(:, 3)); hold on;
figure;
display_transform([1, 0, 0; 0, 1, 0; 0, 0, 1], [0, 0, 0]');
display_transform([H(1,1),  H(1, 2), H(1, 3); ... 
                   H(2, 1), H(2, 2), H(2, 3); ...
                   H(3, 1), H(3,2),  H(3, 3)], [H(1, 4), H(2, 4), H(3, 4)]');
scatter3(X_kept(:, 1), X_kept(:, 2), X_kept(:, 3)); hold off;

% truncate homogeneous coordinates
x = x(1:2, :);
xp = xp(1:2, :);

% figure;
% white_img = 255 * ones(height, width, 'uint8');
% showMatchedFeatures(white_img, white_img, x', xp');

pts_L = x';
pts_R = xp';
img_size = [height, width];

end
