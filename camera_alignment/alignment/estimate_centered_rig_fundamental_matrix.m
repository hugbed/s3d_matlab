function [F, params, inliers, T, Tp] = estimate_rig_fundamental_matrix(matched_pts1, matched_pts2, img_size)

pts1 = matched_pts1;
pts2 = matched_pts2;
[nb_pts, ~] = size(pts1);

% centered pts
T = [1, 0, -img_size(1)/2;
     0, 1, -img_size(2)/2;
     0, 0,  1];
 
Tp = [1, 0, -img_size(1)/2;
      0, 1, -img_size(2)/2;
      0, 0,  1];

pts_1_centered = transform_pts(pts1, T);
pts_2_centered = transform_pts(pts2, Tp);

% to homogeneous
pts1h = [pts_1_centered ones(nb_pts, 1)]';
pts2h = [pts_2_centered ones(nb_pts, 1)]';

% tunable parameters
% todo, should be able to tune tunable parameters
distance_threshold = 0.01; % * sqrt(img_size(1)^2 + img_size(2)^2); % 1% of image diagonal
nb_trials = 2000;
confidence = 0.99;

[~, inliers] = ransac(pts1h, pts2h, nb_pts, nb_trials, ...
                      distance_threshold, confidence, ...
                      @compute_fundamental_matrix, @sampson_distance, 5);

[F, params] = solve_fundamental_matrix(pts1h(:, inliers), pts2h(:, inliers));

% decenter F
F = denormalize_F(F, T, Tp);

end

function F = compute_fundamental_matrix(pts1, pts2)

[F, ~] = solve_fundamental_matrix(pts1, pts2);

end

