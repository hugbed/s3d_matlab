close all;

% simple line
x = 1:100;

% add noise to y

y = x + randi(10, 1, length(x));


[model, inliers] = linear_regression(x, y);

a = model(1);
b = model(2);
c = model(3);

x_line = min(x):max(x);
y_line = (-a*x_line + c)/b;

figure;
plot(x(inliers), y(inliers), 'go'); hold on;
plot(x_line(inliers), y_line(inliers));

d = zeros(length(x), 1);
for i = 1:length(d)
    d(i) = (a*x(i) + b*y(i) + c)^2;
end

d