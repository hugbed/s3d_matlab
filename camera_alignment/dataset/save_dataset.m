function save_dataset(name, img_L, img_R, pts_L, pts_R, F, H1, H2, img_L_rect, img_R_rect)

path = strcat('/home/jon/Projects/s3d_matlab/camera_alignment/dataset/data/', name, '/')

dlmwrite(strcat(path, name, '_F.txt'), F, 'delimiter',' ','precision', '%10.16f');
dlmwrite(strcat(path, name, '_H1_L.txt'), H1, 'delimiter',' ','precision', '%10.16f');
dlmwrite(strcat(path, name, '_H2_R.txt'), H2, 'delimiter',' ','precision', '%10.16f');
dlmwrite(strcat(path, name, '_L.txt'), pts_L, 'delimiter',' ','precision', '%10.16f');
dlmwrite(strcat(path, name, '_R.txt'), pts_R, 'delimiter',' ','precision', '%10.16f');

imwrite(img_L, strcat(path, name, '_L.bmp'));
imwrite(img_R, strcat(path, name, '_R.bmp'));

imwrite(img_L_rect, strcat(path, name, '_L_H1.bmp'));
imwrite(img_R_rect, strcat(path, name, '_R_H2.bmp'));

end