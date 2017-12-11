function [x, P] = kalman_filter(z, x, P, sigma)

F = eye(7);
H = eye(7);
Q = 0.00001 * eye(7);
R = diag(sigma);

% prediction (not necessary with identity F, H, Q)
% x = F*x;
% P = F*P*F' + Q;

% update (innovation)
y = z - H*x;
S = H*P*H' + R;
K = P*H'/S;

% update (estimation)
x = x + K*y;
P = P - K*H*P;

end
