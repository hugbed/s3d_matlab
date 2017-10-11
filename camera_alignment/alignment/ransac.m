% todo: compare with/without numerically unstable parameters (e.g: cz, a_x_f)
% todo: pass compute_model, distance functions as generic callbacks

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
[model, params] = solve_fundamental_matrix(pts1(:, inliers), pts2(:, inliers));

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

d = dist_func(pts1, model, pts2');

end

function model = compute_model(pts1, pts2)

[model, ~] = solve_fundamental_matrix(pts1, pts2);

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

function d = sampson_dist(pts1h, f, pts2h)

pfp = (pts2h * f)';
pfp = pfp .* pts1h;
d = sum(pfp, 1) .^ 2;

% additional step for sampson distance
epl1 = f * pts1h;
epl2 = f' * pts2h';
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