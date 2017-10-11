% Compute orthogonality of rectified image from rectified width and height
function Eo = rectification_orthogonality(h, w, H)

a = [w/2, 0, 1]';
b = [w, h/2, 1]';
c = [w/2, h, 1]';
d = [0, h/2, 1]';
x = b - d;
y = c - a;

a_bar = H*a;
b_bar = H*b;
c_bar = H*c;
d_bar = H*d;
x_bar = b_bar - d_bar;
y_bar = c_bar - a_bar;

Eo = acos((dot(x_bar, y_bar))/(norm(x) * norm(y)));

end