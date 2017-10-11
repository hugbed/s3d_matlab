function show_rectification_orthogonality(h, w, H)

a = [w/2, 0, 1]';
b = [w, h/2, 1]';
c = [w/2, h, 1]';
d = [0, h/2, 1]';

a_bar = H*a;
b_bar = H*b;
c_bar = H*c;
d_bar = H*d;

pts = [a, b, c, d]';
pts_bar = [a_bar, b_bar, c_bar, d_bar]';
plot(pts(:, 1), pts(:, 2), 'bo'); hold on;
plot(pts_bar(:, 1), pts_bar(:, 2), 'ro');
legend('Before Rectification', 'After Rectification');

end