function [f, params, inliers] = estimate_rig_fundamental_matrix(matched_pts1, matched_pts2, img_size)

[pts1, pts2, nb_pts] = center_pts(matched_pts1, matched_pts2, img_size);

% to homogeneous
pts1h = [pts1 ones(nb_pts, 1)]';
pts2h = [pts2 ones(nb_pts, 1)]';

% tunable parameters
% todo, should be able to tune tunable parameters
distance_threshold = 0.01 * sqrt(img_size(1)^2 + img_size(2)^2); % 1% of image diagonal
nb_trials = 5000;
confidence = 0.999;

[f, params, inliers] = ransac(pts1h, pts2h, nb_pts, nb_trials, distance_threshold, confidence);

end

function [pts1, pts2, nb_pts] = center_pts(matched_pts1, matched_pts2, img_size)

HEIGHT = img_size(1);
WIDTH = img_size(2);
x = matched_pts1;
xp = matched_pts2;

pts1 = [x(:, 1) - WIDTH/2, x(:, 2) - HEIGHT/2];
pts2 = [xp(:, 1) - WIDTH/2, xp(:, 2) - HEIGHT/2];

nb_pts = size(pts1, 1);
assert(size(pts2, 1) == nb_pts);

end