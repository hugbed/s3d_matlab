function [pts_L_centered, pts_R_centered, nb_pts] = center_pts(pts_L, pts_R, img_size)

HEIGHT = img_size(1);
WIDTH = img_size(2);
x = pts_L;
xp = pts_R;

pts_L_centered = [x(:, 1) - WIDTH/2, x(:, 2) - HEIGHT/2];
pts_R_centered = [xp(:, 1) - WIDTH/2, xp(:, 2) - HEIGHT/2];

nb_pts = size(pts_L, 1);
assert(size(pts_R, 1) == nb_pts);

end