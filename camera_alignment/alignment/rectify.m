function [img_rectified] = rectify(img, H)

R_in = imref2d(size(img));
R_in.XWorldLimits = R_in.XWorldLimits - mean(R_in.XWorldLimits);
R_in.YWorldLimits = R_in.YWorldLimits - mean(R_in.YWorldLimits);

R_out = imref2d(size(img));

img_rectified = imwarp(img, projective2d(H), 'OutputView', R_out);

end
