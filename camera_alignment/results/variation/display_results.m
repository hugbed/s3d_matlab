close all;

load('all_alignments.mat');
load('all_alignments_filtered_no_u.mat');
load('all_alignments_filtered_u.mat');
load('all_distances.mat');
load('all_distances_filtered_no_u.mat');
load('all_distances_filtered_u.mat');

opt_filtered.LineStyle = '-';
opt_filtered.Color = [84/255 84/255 163/255 0.8];
opt_filtered.LineWidth = 2;

opt_raw.LineStyle = '-';
opt_raw.Color = 'k';
opt_raw.LineWidth = 1;

opt_filtered_u.LineStyle = '-';
opt_filtered_u.Color = [84/255 163/255 84/255 0.8];
opt_filtered_u.LineWidth = 2;

figure;
subplot(2, 1, 1);
plot(all_alignments_filtered_no_u(:, 2), opt_filtered);  hold on;
plot(all_alignments(:, 2), opt_raw);
plot(all_alignments_filtered_u(:, 2), opt_filtered_u); hold off;
title('Roll Angle');
xlabel('Iteration (k)');
ylabel('Angle (rad)');
legend('Filtered Robust Estimation', 'Robust Estimation', 'Filtered Robust Estimation with Control-Input');

% subplot(3, 1, 2);
% plot(mean(all_distances_filtered_no_u, 2), opt_filtered);  hold on;
% plot(mean(all_distances, 2), opt_raw);  hold on;
% plot(mean(all_distances_filtered_u, 2), opt_filtered_u); hold off;
% title('Sampson Error');
% xlabel('Iteration (k)');
% ylabel('Mean Error');
% legend('Filtered Angle', 'Estimated Angle', 'Filtered Angle with Control-Input');

subplot(2, 1, 2);
plot(std(all_distances_filtered_no_u, 0, 2), opt_filtered);  hold on;
plot(std(all_distances, 0, 2), opt_raw);  hold on;
plot(std(all_distances_filtered_u, 0, 2), opt_filtered_u); hold off;
title('Sampson Distance');
xlabel('Iteration (k)');
ylabel('Standard-deviation');
legend('Filtered Robust Estimation', 'Robust Estimation', 'Filtered Robust Estimation with Control-Input');

std_std_distances = std(std(all_distances, 0, 2))
std_std_distances_filtered_no_u = std(std(all_distances_filtered_no_u, 0, 2))
std_std_distances_filtered_u = std(std(all_distances_filtered_u, 0, 2))
std_std_distance_gain_no_u = std_std_distances / std_std_distances_filtered_no_u
std_std_distance_gain_u = std_std_distances / std_std_distances_filtered_u
