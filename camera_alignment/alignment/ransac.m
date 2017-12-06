function [best_model, best_inliers] = ransac(pts1, pts2, nb_pts, nb_trials, threshold, confidence, ...
                                             compute_model_func, dist_func, min_nb_pts)

% make sure there are enough points
assert(nb_pts >= min_nb_pts);

% no inliers at first
best_inliers = false(1, nb_pts);

max_nb_trials = nb_trials;
cur_nb_trials = 0;
best_nb_inliers = 0;

log_one_minus_conf = log(1 - confidence);
one_over_nb_pts = 1 / nb_pts;

while cur_nb_trials < max_nb_trials
    % compute distances with minimum number of samples
    [~, d, sample_indices] = sample_model(pts1, pts2, nb_pts, min_nb_pts, compute_model_func, dist_func);

    % find inliers
    [cur_inliers, cur_nb_inliers] = find_inliers(d, nb_pts, threshold);

    if cur_nb_inliers > best_nb_inliers
        %  replace last best
        best_nb_inliers = cur_nb_inliers;
        best_inliers = cur_inliers;
        best_sample_indices = sample_indices;

        % Update the number of trials
        max_nb_trials = update_nb_trials(one_over_nb_pts, log_one_minus_conf, ...
                                         cur_nb_inliers, max_nb_trials);

    end
    cur_nb_trials = cur_nb_trials + 1;
end

assert(best_nb_inliers >= min_nb_pts);

cur_nb_trials
best_nb_inliers

% get model from best inliers
best_model = compute_model_func(pts1(:, best_inliers), pts2(:, best_inliers));

end

function rand_indices = unique_rand_indices(total_size, nb_indices)

assert(nb_indices <= total_size);

% get nb_indices random indices between 1 -> total_size
rand_indices = randperm(total_size, nb_indices);

end

function [model, d, indices] = sample_model(pts1, pts2, nb_pts, min_nb_pts, compute_model_func, dist_func)

% choose nb_pts unique random rows
indices = unique_rand_indices(nb_pts, min_nb_pts);
model = compute_model_func(pts1(:, indices), pts2(:, indices));
d = dist_func(pts1, model, pts2');

end

function [inliers, nb_inliers] = find_inliers(distance, nb_pts, threshold)

inliers = distance <= threshold;
nb_inliers = sum(inliers);

end

% todo: put back 7
function max_nb_trials = update_nb_trials(one_over_nb_pts, ...
                                          log_one_minus_conf, ...
                                          cur_nb_inliers, max_nb_trials)
                                     
ratio_of_inliers = cur_nb_inliers * one_over_nb_pts;
if ratio_of_inliers > 1 - eps('double')
  new_nb= 0;
else
  ratio = ratio_of_inliers^7;
  if ratio > eps(1)
    log_one_minus_ratio = log(1 - ratio);
    new_nb = ceil(log_one_minus_conf / log_one_minus_ratio);
  else
    new_nb = intmax;
  end
end

if max_nb_trials > new_nb
  max_nb_trials = new_nb;
end

end