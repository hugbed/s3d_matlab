function [Er_mean, Er_std] = rectification_error(pts_L, pts_R, H_L, H_R)

[N, ~] = size(pts_L);
Er = zeros(N, 1);

M_R = zeros(N, 3);
M_P_R = zeros(N, 3);

for i = 1:N
   m = [pts_L(i, :), 1];
   m_p = [pts_R(i, :), 1];
   
   % rectify point correspondances
   m_r = H_L' * m';
   m_p_r = H_R' * m_p';
   
   M_R(i, :) = m_r;
   M_P_R(i, :) = m_p_r;
   
   % error is vertical disparity
   Er(i) = norm(m_r(2) - m_p_r(2));
end

% average and mean of vertical disparities of rectified correspondance
Er_mean = mean(Er);
Er_std = std(Er);

end
