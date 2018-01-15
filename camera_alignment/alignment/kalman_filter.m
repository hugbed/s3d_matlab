function [x, P] = kalman_filter(z, x, P, R, sigmaQ, u)

N = length(x);

F = eye(N);
H = eye(N);
Q = diag(sigmaQ);

% prediction
x = F*x + u;
P = F*P*F' + Q;

% update (innovation)
y = z - H*x;
S = H*P*H' + R;
K = P*H'/S;

% update (estimation)
x = x + K*y;
P = P - K*H*P;

end
