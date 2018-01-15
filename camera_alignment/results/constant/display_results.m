close all;
clear all;

load('all_alignments.mat');
load('all_alignments_filtered.mat');
load('all_distances.mat');
load('all_distances_filtered.mat');

opt_raw.LineStyle = '-';
opt_raw.Color = 'k';
opt_raw.LineWidth = 1;

opt_filtered.LineStyle = '-';
opt_filtered.Color = [84/255 163/255 84/255 0.8];
opt_filtered.LineWidth = 2;

figure;
subplot(2, 1, 1);
plot(all_alignments(:, 2), opt_raw); hold on;
plot(all_alignments_filtered(:, 2), opt_filtered); hold off;
title('Roll Angle');
xlabel('Iteration (k)');
ylabel('Angle (rad)');
legend('Robust Estimation', 'Filtered Robust Estimation');

subplot(2, 1, 2);
plot(std(all_distances, 0, 2), opt_raw); hold on;
plot(std(all_distances_filtered, 0, 2), opt_filtered); hold off;
title('Sampson Distance');
xlabel('Iteration (k)');
ylabel('Standard-deviation');
legend('Robust Estimation', 'Filtered Robust Estimation');


std_std_distances = std(std(all_distances, 0, 2))
std_std_distances_filtered = std(std(all_distances_filtered, 0, 2))
std_std_distance_gain = std_std_distances / std_std_distances_filtered
std_roll_angle = std(all_alignments(:, 2))
std_roll_angle_filtered = std(all_alignments_filtered(:, 2))
std_roll_angle_gain = std_roll_angle / std_roll_angle_filtered
