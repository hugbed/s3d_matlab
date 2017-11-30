function display_transform(R, T)

L = 0.5;

% quiver3(0, 0, 0, L, 0, 0, 'r'); hold on;
% quiver3(0, 0, 0, 0, L, 0, 'g'); hold on;
% quiver3(0, 0, 0, 0, 0, L, 'b'); hold on;

X = L * R * [1 0 0]';
Y = L * R * [0 1 0]';
Z = L * R * [0 0 1]';

T = -R*T;

quiver3(T(1), T(2), T(3), X(1), X(2), X(3), 'r'); hold on;
quiver3(T(1), T(2), T(3), Y(1), Y(2), Y(3), 'g'); hold on;
quiver3(T(1), T(2), T(3), Z(1), Z(2), Z(3), 'b'); hold on;
axis equal;

end

