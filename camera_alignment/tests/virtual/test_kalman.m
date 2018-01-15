close all;
clear variables;

rng(0);

nb_iterations = 400;
nb_pts = 200;
all_distances = zeros(nb_iterations, nb_pts);
all_distances_filtered = zeros(nb_iterations, nb_pts);
all_alignments = zeros(nb_iterations, 7);
all_alignments_filtered = zeros(nb_iterations, 7);

t = [0.5, 0.0, 0.0]';
a = [0.0, 0.0, 0.0]'; % roll, pitch, tilt; (ZYX)

t = zeros(nb_iterations, 3);
a = zeros(nb_iterations, 3);

t(:, 1) = 0.5;
half_nb = floor(nb_iterations/3);

% t(1:nb_iterations, 2) = [0:nb_iterations-1]' ./ (nb_iterations-1) * 0.1;

% a(:, 1) = [0:nb_iterations-1]' ./ (nb_iterations-1) * 0.1;

a(1:half_nb-1, 1) = [0:half_nb-2]' ./ (half_nb-2) * 0.1;
a(half_nb:end, 1) = 0.1;
% a(:, 1) = 0.1;

noise_std = 2;
percent_outliers = 0.4;

x = [0, 0, 0, 0, 0, 0, 0]';
P = eye(7);
% sigma = [3.6816E-4, 5.9837E-7, 7.2080E-6, 0.7405];
% sigmaR = [0.00157635501916582,0.0114623776676131,0.000128660955881975,1.53380570948418, 4.501440771520028e-09, 3.382804186380649e-09, 5.713704686791754e-07];
load('covariances.mat');
R = covariances;
sigmaQ = 0*[0.000001, 0.0001, 0.000001, 0.000001, 0.000001, 0.000000001, 0.000000001];

u = zeros(nb_iterations, 7);
u(2:end, 2) = diff(a(:, 1))';
u(:, 2) = u(:, 2); % + 1E-4*randn(size(u(:, 2)));

for i = 1:nb_iterations

t_i = t(i, :)';
a_i = a(i, :)';

[F_gold, pts_L, pts_R, pts_L_noise, pts_R_noise, X, img_size] = generate_virtual_dataset(t_i, a_i, 200, noise_std, percent_outliers);

% estimate fundamental matrix parameters from noisy points and eliminate outliers
[F, alignment, inliers, T] = estimate_fundamental_matrix(pts_L_noise, pts_R_noise, 'Method', 'LMedS', ...
                                                         'Centered', 'true', 'ImgSize', img_size);

[x, P] = kalman_filter(alignment', x, P, R, sigmaQ, u(i, :)');

alignment_filtered = x';
F_filtered = alignment_to_fundamental_matrix(alignment_filtered);
F_filtered = T' * F_filtered * T;
F_filtered = F_filtered / F_filtered(3, 2);

% compute errors of the estimated geometry from noisy points to perfect points
pts_L_H = pts_L;
pts_R_H = pts_R;
pts_L_H(:, 3) = 1;
pts_R_H(:, 3)= 1;
distances = sampson_distance(pts_L_H', F, pts_R_H);
distances_filtered = sampson_distance(pts_L_H', F_filtered, pts_R_H);

all_distances(i, :) = distances;
all_distances_filtered(i, :) = distances_filtered;
all_alignments(i, :) = alignment;
all_alignments_filtered(i, :) = alignment_filtered;

end

variances = var(all_alignments, 1)
covariances = cov(all_alignments, 1)
all_distances_mean = mean(all_distances, 2);
all_distances_std = std(all_distances');
all_distances_filtered_mean = mean(all_distances_filtered, 2);
all_distances_filtered_std = std(all_distances_filtered');

figure;
title('Sampson Error Over Time');
plot(var(all_distances, 0, 2)); hold on;
plot(var(all_distances_filtered, 0, 2)); hold off;
% set(gca,'YScale','log') 
legend('Error', 'Error with filter')

figure;
title('Alignment Parameters Over Time');
for i = 1:7
   subplot(7, 1, i);
   plot(all_alignments(:, i)); hold on;
   plot(all_alignments_filtered(:, i)); hold off;
%    ylim([-0.4 0.4])
   legend('Alignment', 'Filtered Alignment')
end

fprintf('\nSampson Errors:\n');
fprintf(' Estimation (mean) = %f\n', mean(all_distances_mean));
fprintf(' Estimation (std) = %f\n', mean(all_distances_std));
fprintf(' Filtered Estimation (mean) = %f\n', mean(all_distances_filtered_mean));
fprintf(' Filtered Estimation (std) = %f\n', mean(all_distances_filtered_std));

save('all_alignments.mat', 'all_alignments');
save('all_alignments_filtered.mat', 'all_alignments_filtered');
save('all_distances.mat', 'all_distances');
save('all_distances_filtered.mat', 'all_distances_filtered');