function [F, alignment] = solve_fundamental_matrix(pts1, pts2)

x = pts1;
xp = pts2;

u = x(1, :)';
v = x(2, :)';
up = xp(1, :)';
vp = xp(2, :)';

% solve linear system of equations with pseudo-inverse
A = [ones(length(up), 1), u, vp, up - u, up.*v, v.*vp, u.*vp - up.*v];
b = vp - v;
x = pinv(A)*b;

% decompose solution into parameters
f_a_x = -x(1);
a_z = x(2);
a_f = x(3);
ch_y = x(4);
a_y_f = x(5);
a_x_f = -x(6);
c_z_f = x(7);

alignment = [ch_y, a_z, a_f, f_a_x, a_y_f, a_x_f, c_z_f];

F = [0,      -c_z_f + a_y_f,  ch_y + a_z;
     c_z_f,  -a_x_f,          -1 + a_f;
    -ch_y,    1,               -f_a_x];

end