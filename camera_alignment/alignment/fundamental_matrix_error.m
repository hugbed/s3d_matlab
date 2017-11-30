function Ef = fundamental_matrix_error(m, F, mp)

u = m(1);
v = m(2);

% epipolar line
l = F'*mp;

% perpendicular line through m
l_perp = [l(2), -l(1), (l(1)*v - l(2)*u)]';

% intersection point: p_perp = (u_perp, v_perp, 1)
p_perp = cross(l, l_perp);
u_perp = p_perp(1) / p_perp(3);
v_perp = p_perp(2) / p_perp(3);

Ef = sqrt((u_perp - u)^2 + (v_perp - v)^2);

end
