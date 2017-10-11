function [F, H1_L, H2_R, pts_L, pts_R, img_L_rect, img_R_rect] = load_dataset_outputs(dataset)

dir = strcat('dataset/data/', dataset);

% load base images
img_L_rect = imread(strcat(dir, '/', dataset, '_L_H1.bmp'));
img_R_rect = imread(strcat(dir, '/', dataset, '_R_H2.bmp'));

% load fundamental matrix and rectification matrices
F = dlmread(strcat(dir, '/', dataset, '_F.txt'));
H1_L = dlmread(strcat(dir, '/', dataset, '_H1_L.txt'))';
H2_R = dlmread(strcat(dir, '/', dataset, '_H2_R.txt'))';

% load feature points
pts_L = dlmread(strcat(dir, '/', dataset, '_L.txt'));
pts_R = dlmread(strcat(dir, '/', dataset, '_R.txt'));

end