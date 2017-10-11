function [Ef_mean, Ef_std] = fundamental_matrix_errors(pts_L, F, pts_R)

[N, ~] = size(pts_L);
Ef = zeros(N, 1);
for i = 1:N
   u = pts_L(i, 1);
   v = pts_L(i, 2);
   up = pts_R(i, 1);
   vp = pts_R(i, 2);
   Ef(i) = fundamental_matrix_error([u, v, 1], F, [up, vp, 1]');
end

Ef_mean = mean(Ef);
Ef_std = std(Ef);

end