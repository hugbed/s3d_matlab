function [matched_pts1, matched_pts2] = find_matches(img1, img2)

% detect features
points1 = detectSURFFeatures(img1);
points2 = detectSURFFeatures(img2);

% extract features
[features1, points1] = extractFeatures(img1, points1);
[features2, points2] = extractFeatures(img2, points2);

% match features
featuresPairs = matchFeatures(features1, features2);

% filter matched pairs
matched_pts1 = points1(featuresPairs(:, 1), :);
matched_pts2 = points2(featuresPairs(:, 2), :);

end