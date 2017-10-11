% Compute aspect ratio of rectified image from rectified width and height
function Ea = rectification_aspect_ratio(h, w, H)

a = [0, 0, 1]';
b = [w, 0, 1]';
c = [w, h, 1]';
d = [0, h, 1]';

a_bar = H*a;
b_bar = H*b;
c_bar = H*c;
d_bar = H*d;
x_bar = b_bar - d_bar;
y_bar = c_bar - a_bar;

Ea = sqrt((x_bar' * x_bar) / (y_bar' * y_bar));

end