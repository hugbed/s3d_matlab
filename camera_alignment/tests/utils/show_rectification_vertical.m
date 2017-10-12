function [Er_mean, Er_std] = show_rectification_vertical(pts_L, pts_R, H_L, H_R)

[N, ~] = size(pts_L);
Er = zeros(N, 1);

M = zeros(N, 3);
M_P = zeros(N, 3);
LINES = zeros(N, 4);

M_R = zeros(N, 3);
M_P_R = zeros(N, 3);
LINES_R = zeros(N, 4);

for i = 1:N
   m = [pts_L(i, :), 1];
   m_p = [pts_R(i, :), 1];
   
   % rectify point correspondances
   m_r = H_L' * m';
   m_p_r = H_R' * m_p';
   
   M(i, :) = m;
   M_P(i, :) = m_p;
   LINES(i, 1:2) = m(1:2)';
   LINES(i, 3:4) = m_p(1:2)';
   
   M_R(i, :) = m_r;
   M_P_R(i, :) = m_p_r;
   LINES_R(i, 1:2) = m_r(1:2)';
   LINES_R(i, 3:4) = m_p_r(1:2)';
   
   % error is vertical disparity
   Er(i) = norm(m_r(2) - m_p_r(2));
end

subplot(1, 2, 1);
plot(M(:, 1), M(:, 2), 'ro'); axis ij; hold on;
plot(M_P(:, 1), M_P(:, 2), 'bo'); axis ij; hold on;
line(LINES(:,[1,3])', LINES(:,[2,4])'); hold on;
title('Disparities Before');

subplot(1, 2, 2);
plot(M_R(:, 1), M_R(:, 2), 'ro'); axis ij; hold on;
plot(M_P_R(:, 1), M_P_R(:, 2), 'bo'); axis ij; hold on;
line(LINES_R(:,[1,3])', LINES_R(:,[2,4])'); hold on;
title('Disparities After');

% average and mean of vertical disparities of rectified correspondance
Er_mean = mean(Er);
Er_std = std(Er);

end