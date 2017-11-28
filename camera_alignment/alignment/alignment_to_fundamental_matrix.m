function F = solve_fundamental_matrix(alignment)

ch_y = alignment(1);
a_z = alignment(2);
a_f = alignment(3);
f_a_x = alignment(4);
a_y_f = alignment(5);
a_x_f = alignment(6);
c_z_f = alignment(7);

F = [0,      -c_z_f + a_y_f,  ch_y + a_z;
     c_z_f,  -a_x_f,          -1 + a_f;
    -ch_y,    1,               -f_a_x];

end