function [img_rectified] = rectify(img, H)

% nb_rows = size(img, 1)
% nb_cols = size(img, 2)
% 
% H_off = [1.0, 0.0, nb_cols/ 2.0;
%          0.0, 1.0, nb_rows / 2.0;
%          0.0, 0.0, 1.0];
%     
% H_off_T = [1.0, 0.0, -nb_cols/ 2.0;
%            0.0, 1.0, -nb_rows / 2.0;
%            0.0, 0.0,  1.0];
%
% H_total = (H_off * H * H_off_T);       

R_in = imref2d(size(img));
R_in.XWorldLimits = R_in.XWorldLimits - mean(R_in.XWorldLimits);
R_in.YWorldLimits = R_in.YWorldLimits - mean(R_in.YWorldLimits);

R_out = imref2d(size(img));
% R_out.XWorldLimits = R_out.XWorldLimits + 50; % + mean(R_out.XWorldLimits);
% R_out.YWorldLimits = R_out.YWorldLimits + 50; % + mean(R_out.YWorldLimits);

img_rectified = imwarp(img, projective2d(H), 'OutputView', R_out);

end
