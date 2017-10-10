function [img_L, img_R] = load_dataset_inputs(dataset)

dir = strcat('dataset/data/', dataset);

% load base images
img_L_RGB = imread(strcat(dir, '/', dataset, '_L.bmp'));
img_R_RGB = imread(strcat(dir, '/', dataset, '_R.bmp'));

% convert to grayscale
img_L = rgb2gray(img_L_RGB);
img_R = rgb2gray(img_R_RGB);

end