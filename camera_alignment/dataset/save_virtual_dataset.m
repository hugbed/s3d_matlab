function save_virtual_dataset(name, C, R, t, pts_L, pts_R, img_size)

path = strcat('/home/jon/Projects/s3d_matlab/camera_alignment/dataset/virtual/', name, '/')

dlmwrite(strcat(path, name, '_C.txt'), C, 'delimiter',' ','precision', '%10.16f');
dlmwrite(strcat(path, name, '_R.txt'), R, 'delimiter',' ','precision', '%10.16f');
dlmwrite(strcat(path, name, '_t.txt'), t, 'delimiter',' ','precision', '%10.16f');
dlmwrite(strcat(path, name, '_L.txt'), pts_L, 'delimiter',' ','precision', '%10.16f');
dlmwrite(strcat(path, name, '_R.txt'), pts_R, 'delimiter',' ','precision', '%10.16f');
dlmwrite(strcat(path, name, '_imgsize.txt'), img_size, 'delimiter',' ','precision', '%10.16f');

end
