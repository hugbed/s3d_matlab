function new_alignment = iterative_fundamental_matrix(alignment, pts_L, pts_R, T, Tp)

pts_L_H = pts_L;
pts_R_H = pts_R;

pts_L_H(:, 3) = 1;
pts_R_H(:, 3) = 1;

options = optimset('Display','off');
% [new_alignment error] = lsqnonlin(@sampson_dist_alignment, alignment, [], [], options, pts_L_H', pts_R_H');

alignment

TOL_X = 1e-4; TOL_FUN = 1e-4; MAX_FUN_EVAL = 1e4; MAX_ITER = 1e3;

[new_alignment, error] = lsqnonlin(@sampson_dist_alignment, double(alignment),[],[], ...
                                   optimset('Display','iter', ...
                                   'TolX',TOL_X,'TolFun',TOL_FUN,'MaxFunEval',MAX_FUN_EVAL,'MaxIter',MAX_ITER, ...
                                   'Algorithm', {'levenberg-marquardt' 0.01}), pts_L_H', pts_R_H', T, Tp)                             

end

function d = sampson_dist_alignment(alignment, pts_L, pts_R, T, Tp)

F = alignment_to_fundamental_matrix(alignment);
F = denormalize_F(F, T, Tp);

d = sampson_distance(pts_L, F, pts_R');

end