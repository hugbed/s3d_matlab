close all;
clear variables;

% load dataset images
dataset_name = '2';
[C, R, t, pts_L, pts_R] = load_virtual_dataset(dataset_name);

% compute fundamental matrix
[F, alignment] = solve_fundamental_matrix(pts_L', pts_R');

fprintf('Results:\n');
fprintf(' vertical (degrees) = %f\n', alignment(1) * 180 / pi);
fprintf(' roll (degrees) = %f\n', alignment(2) * 180 / pi);
fprintf(' zoom (percent) = %f\n', (alignment(3) + 1.0) * 100.0);
fprintf(' tiltOffset (pixels) = %f\n', alignment(4));
fprintf(' tiltKeystone (radians / m) = %f\n', alignment(5));
fprintf(' panKeystone (radians / m) = %f\n', alignment(6));
fprintf(' zParallaxDeformation (m/m) = %f\n', alignment(7));
