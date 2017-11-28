function [ C, R, t, pts_L, pts_R, img_size ] = load_virtual_dataset(dataset)

path = strcat('/home/jon/Projects/s3d_matlab/camera_alignment/dataset/virtual/', dataset, '/');

C = dlmread(strcat(path, '/', dataset, '_C.txt'));
R = dlmread(strcat(path, '/', dataset, '_R.txt'));
t = dlmread(strcat(path, '/', dataset, '_t.txt'));
pts_L = dlmread(strcat(path, '/', dataset, '_L.txt'));
pts_R = dlmread(strcat(path, '/', dataset, '_R.txt'));
img_size = dlmread(strcat(path, '/', dataset, '_imgsize.txt'));

end

