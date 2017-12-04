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
expectedMethods = {'RANSAC', 'MSAC', 'STAN'};
expectedBoolean = {'true', 'false'};

defaultMethod = 'RANSAC';
defaultCentered = 'false';
defaultImgSize = [-1, -1];
defaultNbTrials = 500;
defaultDistanceThreshold = 1.96 * 2;
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
