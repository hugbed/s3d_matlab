function [img1_rectified, img2_rectified] = rectify_alignment(img1, img2, alignment)

[nb_rows, nb_cols] = size(img1);

ch_y = alignment(1);   % vertical
a_z = alignment(2);    % roll
a_f = alignment(3);    % zoom
f_a_x = alignment(4);  % tiltOffset
a_x_f = alignment(5);  % tiltKeystone
a_y_f = alignment(6);  % panKeystone
ch_z_f = alignment(7); % zParallaxDeformation

H_off = [1.0, 0.0, nb_cols/ 2.0;
         0.0, 1.0, nb_rows / 2;
         0.0, 0.0, 1.0];
    
H_off_T = [1.0, 0.0, nb_cols/ 2.0;
           0.0, 1.0, nb_rows / 2;
           0.0, 0.0, 1.0];

H = [1.0,  ch_y, 0.0;
    -ch_y, 1.0, 0.0;
    -ch_z_f, 0, 1]

Hp = [1 - a_f, a_z + ch_y, 0;
     -(a_z + ch_y), 1 - a_f, -f_a_x;
      a_y_f - ch_z_f, -a_x_f, 1]
  
img1_rectified = imwarp(img1, projective2d((H_off_T * H * H_off)'));
img2_rectified = imwarp(img2, projective2d((H_off_T * Hp * H_off)'));

end
