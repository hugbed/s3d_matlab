function disparity_range = analyze_disparities(matched_pts1, matched_pts2, inliers, img_width)

pts1 = matched_pts1(inliers).Location;
pts2 = matched_pts2(inliers).Location;

disparities = pts2(:, 1) - pts1(:, 1);

% to screen width percent
disparities = disparities ./ img_width * 100;

near_clip_plane_d = prctile(disparities, 2);
far_clip_plane_d = prctile(disparities, 99);

figure;
histogram(disparities, 10); hold on;
line([near_clip_plane_d near_clip_plane_d],[0 60], 'LineWidth', 2);
line([far_clip_plane_d far_clip_plane_d],[0 60], 'LineWidth', 2, 'Color', 'g');
title('Disparity distribution histogram');

disparity_range = far_clip_plane_d - near_clip_plane_d;

end