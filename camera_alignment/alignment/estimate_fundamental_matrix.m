function [F, varargout] = estimate_fundamental_matrix(matched_pts1, matched_pts2, varargin)
                       
% Parse and check inputs
[pts1, pts2, method, distance_function, ...
 nb_trials, distance_threshold, confidence, centered, img_size] ...
 = parse_inputs(matched_pts1, matched_pts2, varargin{:});

T = eye(3);
if centered
  T = center_transform(img_size);
  pts1 = transform_pts(pts1, T);
  pts2 = transform_pts(pts2, T);
end

[F, alignment, inliers] = estimateFundamentalMatrixAlg(...
  pts1, pts2, method, nb_trials, ...
  distance_function, distance_threshold, confidence);

% [F, alignment, inliers] = guided_matching(alignment, inliers, pts1, pts2, 2*distance_threshold);

if centered
  F = decenter_F(F, T);
end

if nargout >= 2
  varargout{1} = alignment;
  if nargout >= 3
    varargout{2} = inliers;
  end
  if nargout >= 4
    varargout{3} = T; 
  end
end
    
end

function [pts1, pts2, method, distance_function, ...,
          nb_trials, distance_treshold, confidence, centered, img_size] ... 
            = parse_inputs(matched_pts1, matched_pts2, varargin)

% should add LMedS, LTS, MSAC
expectedMethods = {'RANSAC', 'MSAC', 'STAN', 'LMedS'};
expectedBoolean = {'true', 'false'};

expected_std = 3;

defaultMethod = 'LMedS';
defaultCentered = 'false';
defaultImgSize = [-1, -1];
defaultNbTrials = 500;
defaultDistanceThreshold = sqrt(3.84*expected_std^2); % 95% inlier (see [Hartley])
defaultConfidence = 99;

p = inputParser;
addOptional(p, 'Method', defaultMethod, @(x) any(validatestring(x,expectedMethods)));
addOptional(p, 'Centered', defaultCentered, @(x) any(validatestring(x,expectedBoolean)));
addOptional(p, 'ImgSize', defaultImgSize, @check_img_size);
addOptional(p, 'DistanceFunction', @sampson_distance, @(f) isa(f, 'function_handle'));
addOptional(p, 'MaxNbTrials', defaultNbTrials, @check_nb_trials);
addOptional(p, 'DistanceThreshold', defaultDistanceThreshold, @check_threshold);
addOptional(p, 'Confidence', defaultConfidence, @check_percentage);

parse(p, varargin{:});

pts1 = check_and_convert_pts(matched_pts1);
pts2 = check_and_convert_pts(matched_pts2);
method = p.Results.Method;
centered = strcmp(p.Results.Centered, 'true');
img_size = p.Results.ImgSize;
distance_function = p.Results.DistanceFunction;
nb_trials = p.Results.MaxNbTrials;
distance_treshold = p.Results.DistanceThreshold;
confidence = p.Results.Confidence / 100;

if centered == true && isequal(img_size, defaultImgSize)
    error('ImgSize must be set if "Centered" is set to true');
end

end

function r = check_nb_trials(value)
validateattributes(value, {'numeric'}, ...
  {'scalar', 'nonsparse', 'real', 'integer', 'positive', 'finite'});
r = 1;
end

function r = check_threshold(value)
validateattributes(value, {'numeric'}, ...
  {'scalar', 'nonsparse', 'real', 'positive', 'finite'});
r = 1;
end

function r = check_percentage(value)
validateattributes(value, {'numeric'}, ...
  {'scalar', 'nonsparse', 'real', 'positive', 'finite', '<', 100});
r = 1;
end

function r = check_img_size(value)
validateattributes(value, {'numeric'}, ...
  {'2d', 'nonsparse', 'real', 'integer', 'positive', 'finite'});
r = 1;
end

function pts = check_and_convert_pts(pts)
validateattributes(pts, {'numeric'}, ...
  {'2d', 'real', 'finite'});
if ~(size(pts, 1) == 2)
   pts = pts'; 
end
end

function T = center_transform(img_size)
T = [1, 0, -img_size(1)/2;
     0, 1, -img_size(2)/2;
     0, 0,  1];
end

function pts_transformed = transform_pts(pts, T)
N = size(pts, 2);
pts(3, :) = 1;
pts_H = T*pts;
pts_transformed = pts_H(1:2, :);
end

function F = decenter_F(F, T)
F = T' * F * T;
F = F / F(3, 2);
end

function [F, alignment, inliers] = estimateFundamentalMatrixAlg(...
  pts1, pts2, method, nb_trials, ...
  distance_function, distance_threshold, confidence)

nb_pts = size(pts1, 2);
inliers = false(nb_pts, 1);

% pts to homogeneous
pts1(3, :) = 1;
pts2(3, :) = 1;

if strcmp(method, 'STAN')
  if nb_pts >= 7
    [F, alignment] = stan_fundamental_matrix(pts1, pts2);
    inliers(:) = true(1, nb_pts);
  else
    % error
  end
else
  switch method
    case 'RANSAC'
      [~, inliers] = ransac(pts1, pts2, nb_pts, nb_trials, ...
                      distance_threshold, confidence, ...
                      @compute_fundamental_matrix, distance_function, 7); % todo: this min_nb_pts is hardcoded!
    case 'MSAC'
      [inliers] = msac(pts1, pts2, nb_pts, nb_trials, ...
                       distance_threshold, confidence, ...
                       @compute_fundamental_matrix, distance_function, 7);
    case 'LMedS'
      [inliers] = lmeds(pts1, pts2, nb_pts, nb_trials, ...
                       distance_threshold, confidence, ...
                       @compute_fundamental_matrix, distance_function, 7);
  end
  
  % if no error
  [F, alignment] = stan_fundamental_matrix(pts1(:, inliers), pts2(:, inliers));
end
end

function F = compute_fundamental_matrix(pts1, pts2)
[F, ~] = stan_fundamental_matrix(pts1, pts2);
end

function [inliers] = msac(pts1h, pts2h, nb_pts, nb_trials, confidence, distance_threshold, ...
  compute_fundamental_matrix, distance_function, sample_size)

inliers = false(1, nb_pts);
if nb_pts >= 7
    
    ransacParams.maxNumTrials = nb_trials;
    ransacParams.confidence = confidence;
    ransacParams.maxDistance = distance_threshold;
    ransacParams.sampleSize = sample_size;
    ransacParams.recomputeModelFromInliers = false;
    
    ransacFuncs.checkFunc = @checkTForm;
    ransacFuncs.fitFunc = @computeTForm;
    ransacFuncs.evalFunc = @evaluateTFormSampson;
  
    points = cat(3, pts1h', pts2h');
    [isFound, ~, inliers] = vision.internal.ransac.msac(...
        points, ransacParams, ransacFuncs);
    
    if ~isFound 
        error('Not enough inliers');
    end
else
    error('Not enough points');
end
end

function inliers = lmeds(pts1h, pts2h, nb_pts, nb_trials, confidence, distance_threshold, ...
  compute_fundamental_matrix, distance_function, sample_size)

inliers = false(1, nb_pts);
bestDis = realmax('double');
bestModel = zeros(3, 3);

if nb_pts >= 2*sample_size
  for idx = 1: nb_trials
   [model, d, ~] = sample_model(pts1h, pts2h, nb_pts, sample_size, compute_fundamental_matrix, distance_function);
  
    curDis = median(d);
    if bestDis > curDis
      bestDis = curDis;
      bestModel = model;
    end
  end

  if bestDis < realmax('double')
    d = distance_function(pts1h, bestModel, pts2h');
    inliers = (d <= bestDis);
  else
    error('Not enough inliers');
  end
else
  error('Not enough points');
end
end

function F = computeTForm(points)
points1 = points(:,:,1)';
points2 = points(:,:,2)';
F = compute_fundamental_matrix(points1, points2);
end

function dis = evaluateTFormSampson(F, points)
points1 = points(:, :, 1)';
points2 = points(:, :, 2)';
dis = sampson_distance(points1, F, points2')';
end

function tf = checkTForm(tform)
tf = all(isfinite(tform(:)));
end

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
    [cur_inliers, cur_nb_inliers] = find_inliers(d, threshold);

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

cur_nb_trials;
best_nb_inliers;

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

function [inliers, nb_inliers] = find_inliers(distance, threshold)

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

function [F, alignment, inliers] = guided_matching(alignment, inliers, pts1, pts2, distance_threshold)

nb_inliers = sum(inliers);
last_nb_inliers = 0;

pts1h = pts1;
pts2h = pts2;
pts1h(3, :) = 1;
pts2h(3, :) = 1;

while ~(nb_inliers == last_nb_inliers)

last_nb_inliers = nb_inliers;

alignment = iterative_fundamental_matrix(alignment, pts1h(:, inliers), pts2h(:, inliers));

F = alignment_to_fundamental_matrix(alignment);
d = sampson_distance(pts1h, F, pts2h');
[inliers, nb_inliers] = find_inliers(d, distance_threshold);

% nb_inliers

end

F = alignment_to_fundamental_matrix(alignment);

end

