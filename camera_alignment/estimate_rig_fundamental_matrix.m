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

% todo: compare with/without numerically unstable parameters (e.g: cz, a_x_f)
function [model, params, inliers] = ransac(pts1, pts2, nb_pts, nb_trials, threshold, confidence)

min_nb_pts = 5;

% make sure there are enough points
assert(nb_pts >= min_nb_pts);

% no inliers at first
inliers = false(1, nb_pts);

max_nb_trials = nb_trials;
cur_nb_trials = 0;
best_nb_inliers = 0;

log_one_minus_conf = log(1 - confidence);
one_over_nb_pts = 1 / nb_pts;

while cur_nb_trials < max_nb_trials
    % compute distances with minimum number of samples
    [~, d] = sample_model(pts1, pts2, nb_pts, min_nb_pts, @sampson_dist);

    % find inliers
    [cur_inliers, cur_nb_inliers] = find_inliers(d, nb_pts, threshold);

    if cur_nb_inliers > best_nb_inliers
        %  replace last best
        best_nb_inliers = cur_nb_inliers;
        inliers = cur_inliers;

        % Update the number of trials
        max_nb_trials = update_nb_trials(one_over_nb_pts, log_one_minus_conf, ...
                                         cur_nb_inliers, max_nb_trials);


    end
    cur_nb_trials = cur_nb_trials + 1;
end

assert(best_nb_inliers >= min_nb_pts);

% get model from best inliers
[model, params] = compute_model_with_params(pts1(:, inliers), pts2(:, inliers));

end

function [pts1, pts2, nb_pts] = center_pts(matched_pts1, matched_pts2, img_size)

HEIGHT = img_size(1);
WIDTH = img_size(2);
x = matched_pts1.Location;
xp = matched_pts2.Location;

pts1 = [x(:, 1) - WIDTH/2, x(:, 2) - HEIGHT/2];
pts2 = [xp(:, 1) - WIDTH/2, xp(:, 2) - HEIGHT/2];

nb_pts = size(pts1, 1);
assert(size(pts2, 1) == nb_pts);

end

function rand_indices = unique_rand_indices(total_size, nb_indices)

assert(nb_indices <= total_size);

% get nb_indices random indices between 1 -> total_size
rand_indices = randperm(total_size, nb_indices);

end

function [model, d] = sample_model(pts1, pts2, nb_pts, min_nb_pts, dist_func)

% choose nb_pts unique random rows
rand_indices = unique_rand_indices(nb_pts, min_nb_pts);
model = compute_model(pts1(:, rand_indices), pts2(:, rand_indices));

d = dist_func(pts1, pts2, model);

end

function model = compute_model(pts1, pts2)

[model, ~] = compute_model_with_params(pts1, pts2);

end

function [model, params] = compute_model_with_params(pts1, pts2)

x = pts1;
xp = pts2;

u = x(1, :)';
v = x(2, :)';
up = xp(1, :)';
vp = xp(2, :)';

% solve linear system of equations with pseudo-inverse
A = [up - u, up, vp, -ones(length(up)), up.*v, -v.*vp]; %, u.*vp - up.*v];
x = pinv(A)*(vp - v);

% decompose solution into parameters
ch_y = x(1); % percent?
a_z = x(2); % rad2deg(x(2)) % degrees
a_f = x(3); % (x(3) + 1) * 100 % percent
f_a_x = x(4);
a_y_f = x(5);
a_x_f = 0; %x(6);
ch_z_f = 0; %x(7);

params = [ch_y, a_z, a_f, f_a_x, a_y_f, a_x_f, ch_z_f];

model = [0,      -ch_z_f + a_y_f,  ch_y + a_z;
         ch_z_f  -a_x_f,          -1 + a_f;
        -ch_y     1,               -f_a_x];

end

function [inliers, nb_inliers] = find_inliers(distance, nb_pts, threshold)

inliers = false(1, nb_pts);
nb_inliers = 0;

for idx = 1: nb_pts
  if (distance(idx) <= threshold)
    inliers(idx) = true;
    nb_inliers = nb_inliers + 1;
  else
    inliers(idx) = false;
  end
end

end

function d = sampson_dist(pts1h, pts2h, f)

pfp = (pts2h' * f)';
pfp = pfp .* pts1h;
d = sum(pfp, 1) .^ 2;

% additional step for sampson distance
epl1 = f * pts1h;
epl2 = f' * pts2h;
d = d ./ (epl1(1,:).^2 + epl1(2,:).^2 + epl2(1,:).^2 + epl2(2,:).^2);

end

function max_nb_trials = update_nb_trials(one_over_nb_pts, ...
                                          log_one_minus_conf, ...
                                          cur_nb_inliers, max_nb_trials)
                                     
ratio_of_inliers = cur_nb_inliers * one_over_nb_pts;
if ratio_of_inliers > 1 - eps('double')
  new_nb= 0;
else
  ratio7 = ratio_of_inliers^7;
  if ratio7 > eps(1)
    log_one_minus_ratio7 = log(1 - ratio7);
    new_nb = ceil(log_one_minus_conf / log_one_minus_ratio7);
  else
    new_nb = intmax;
  end
end

if max_nb_trials > new_nb
  max_nb_trials = new_nb;
end

end