function show_epilines(img_L, img_R, F, pts_L, pts_R)

lines_L = epipolarLine(F', pts_R);
lines_R = epipolarLine(F, pts_L);
border_pts_L = lineToBorderPoints(lines_L, size(img_L));
border_pts_R = lineToBorderPoints(lines_R, size(img_R));

figure;
subplot(1, 2, 1);
imshow(img_L); hold on;
plot(pts_L(:, 1), pts_L(:, 2), 'go'); hold on;
line(border_pts_L(:,[1,3])', border_pts_L(:,[2,4])');
title('Inliers and Epipolar Lines (Left Image)');

subplot(1, 2, 2);
imshow(img_R); hold on;
plot(pts_R(:, 1), pts_R(:, 2), 'go'); hold on;
line(border_pts_R(:,[1,3])', border_pts_R(:,[2,4])');
title('Inliers and Epipolar Lines (Right Image)');

end