function [img_rectified] = rectify(img, H)

[nb_rows, nb_cols] = size(img);

H_off = [1.0, 0.0, nb_cols/ 2.0;
         0.0, 1.0, nb_rows / 2.0;
         0.0, 0.0, 1.0];
    
H_off_T = [1.0, 0.0, -nb_cols/ 2.0;
           0.0, 1.0, -nb_rows / 2.0;
           0.0, 0.0,  1.0];
       
R = imref2d(size(img), [1 size(img,2)], [1, size(img,1)]);

H_total = (H_off_T * H * H_off)';

img_rectified = imwarp(img, projective2d(H), 'OutputView', R);

end
