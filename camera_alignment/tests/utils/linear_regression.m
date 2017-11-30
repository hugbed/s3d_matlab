function [model, inliers] = linear_regression(x, y)

distance_threshold = 1
confidence = 0.999
nb_trials = 2000
nb_pts = length(x)

[model, inliers] = ransac(x, y, nb_pts, nb_trials, ...
                      distance_threshold, confidence, ...
                      @compute_line, @least_square_distance, 2);

end

function model = compute_line(x, y)

x1 = x(1);
x2 = x(2);
y1 = y(1);
y2 = y(2);

dx = x2 - x1;
dy = y2 - y1;
d_norm = sqrt(dx*dx + dy*dy);

a = -dy/d_norm;
b = dx/d_norm;
c = a * x1 + b * y1;

model = [a, b, c]

end

function d = least_square_distance(x, model, y)

a = model(1);
b = model(2);
c = model(3);

d = zeros(length(x), 1);
for i = 1:length(d)
    d(i) = (a*x(i) + b*y(i) + c)^2;
end

end