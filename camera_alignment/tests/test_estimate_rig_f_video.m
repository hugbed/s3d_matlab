close all;

% load video
videoReader = VideoReader('/home/jon/Documents/bbb_sunflower_1080p_30fps_stereo_abl.mp4');

while hasFrame(videoReader)

    img = readFrame(videoReader);
    
    imshow(img);
    
%     % find feature matches
%     [matched_pts1, matched_pts2] = find_matches(img_L, img_R);
% 
%     % estimate fundamental matrix parameters and eliminate outliers
%     [F, alignment, inliers] = estimate_rig_fundamental_matrix(matched_pts1.Location, matched_pts2.Location, size(img_L));
% 
%     % [F, inliers] = estimateFundamentalMatrix(matched_pts1, matched_pts2, 'Method', 'RANSAC', 'NumTrials', 2000);
%     pts_L_inliers = matched_pts1.Location(inliers, :);
%     pts_R_inliers = matched_pts2.Location(inliers, :);
%     [NB_INLIERS, ~] = size(pts_L_inliers);
% 
%     % [T1,T2] = estimateUncalibratedRectification(F,matched_pts1(inliers),matched_pts2(inliers), size(img_L))
%     [T1, T2] = compute_rectification(alignment);
% 
%     % draw epilines on image
%     [img_L_epilines, img_R_epilines] = draw_epilines(img_L, img_R, F, pts_L_inliers, pts_R_inliers);
% 
%     % rectify images
%     [img_L_rectified, img_R_rectified] = rectifyStereoImages(img_L_epilines, img_R_epilines, projective2d(T1), projective2d(T2));
% 
%     figure;
%     subplot(2, 1, 1); imshow(horzcat(img_L_epilines, img_R_epilines)); title('Epilines Before Rectification');
%     subplot(2, 1, 2); imshow(horzcat(img_L_rectified, img_R_rectified)); title('Epilines After Rectification');
    
end

