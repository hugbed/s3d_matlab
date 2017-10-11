function show_rectification_aspect_ratio(h, w, H)

a = [0, 0, 1]';
b = [w, 0, 1]';
c = [w, h, 1]';
d = [0, h, 1]';

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