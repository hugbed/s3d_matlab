function new_alignment = iterative_fundamental_matrix(alignment, pts1h, pts2h)

TOL_X = 1e-4; TOL_FUN = 1e-4; MAX_FUN_EVAL = 1e4; MAX_ITER = 1e3;

[new_alignment, error] = lsqnonlin(@sampson_dist_alignment, double(alignment),[],[], ...
                                   optimset('Display','off', ...
                                   'TolX',TOL_X,'TolFun',TOL_FUN,'MaxFunEval',MAX_FUN_EVAL,'MaxIter',MAX_ITER, ...
                                   'Algorithm', {'levenberg-marquardt' 0.01}), pts1h, pts2h);

end

function d = sampson_dist_alignment(alignment, pts1h, pts2h)

F = alignment_to_fundamental_matrix(alignment);
d = sampson_distance(pts1h, F, pts2h');
d = double(d);

end