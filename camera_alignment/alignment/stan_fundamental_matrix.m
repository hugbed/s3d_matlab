function [F, alignment] = stan_fundamental_matrix(pts1, pts2)
% rename solve_stan_alignment

x = pts1;
xp = pts2;

u = x(1, :)';
v = x(2, :)';
up = xp(1, :)';
vp = xp(2, :)';

% solve linear system of equations
A = [up - u, up, vp, -ones(length(up), 1), up.*v]; %, -v.*vp, u.*vp - up.*v];
b = vp - v;
x = A \ b;

% decompose solution into parameters
ch_y = x(1);
a_z = x(2);
a_f = x(3);
f_a_x = x(4);
a_y_f = x(5);
a_x_f = 0.0; %x(6);
c_z_f = 0.0; %x(7);

alignment = [ch_y, a_z, a_f, f_a_x, a_y_f, a_x_f, c_z_f];

F = alignment_to_fundamental_matrix(alignment);

end
