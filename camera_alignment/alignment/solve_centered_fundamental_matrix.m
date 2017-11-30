function [F, alignment, T, Tp] = solve_centered_fundamental_matrix(pts_L, pts_R, img_size)

T = [1, 0, -img_size(1)/2;
     0, 1, -img_size(2)/2;
     0, 0,  1];
 
Tp = [1, 0, -img_size(1)/2;
      0, 1, -img_size(2)/2;
      0, 0,  1];

pts_L_centered = transform_pts(pts_L, T);
pts_R_centered = transform_pts(pts_R, Tp);
 
% estimate fundamental matrix parameters and eliminate outliers
[F, alignment] = solve_fundamental_matrix(pts_L_centered', pts_R_centered');

% decenter F
F = denormalize_F(F, T, Tp)

end