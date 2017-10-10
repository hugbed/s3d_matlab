
pts1 = [0, 1;
        1, 0;
       -1, 0;
        0,-1];

% % should give 0
% pts2 = [0, 1;
%         1, 0;
%        -1, 0;
%         0,-1];

% should give 1 pixel vertical
vertical_offset = 10;
pts2 = [pts1(:, 1), pts1(:, 2) + vertical_offset];

x = pts1;
xp = pts2;

u = x(1, :)';
v = x(2, :)';
up = xp(1, :)';
vp = xp(2, :)';

% solve linear system of equations with pseudo-inverse
A = [up - u, up, vp, -ones(length(up), 1), up.*v, -v.*vp, u.*vp - up.*v];
x = pinv(A)*(vp - v);

% decompose solution into parameters
ch_y = x(1);
a_z = x(2);
a_f = x(3);
f_a_x = x(4);
a_y_f = x(5);
a_x_f = 0; %x(6);
ch_z_f = 0; %x(7);

params = [ch_y, a_z, a_f, f_a_x, a_y_f, a_x_f, ch_z_f];

model = [0,      -ch_z_f + a_y_f,  ch_y + a_z;
         ch_z_f  -a_x_f,          -1 + a_f;
        -ch_y     1,               -f_a_x]

% verify that m'T * F * m = 0
pts1_h = [pts1, ones(4,1)];
pts2_h = [pts1, ones(4,1)];
for i = 1:4
    vertical_shift = ch_y * (pts2_h(1) - pts1_h(1))
    constraint = pts1_h(2, :) * model * pts2_h(2, :)'
end
    
fprintf('Results:\n');
fprintf('\t vertical (degrees) = %f\n', params(1) * 180 / pi);
fprintf('\t roll (degrees) = %f\n', params(2) * 180 / pi);
fprintf('\t zoom (percent) = %f\n', (params(3) + 1.0) * 100.0);
fprintf('\t tiltOffset (percent) = %f\n', params(4));
fprintf('\t tiltKeystone (pixels) = %f\n', params(5));
fprintf('\t panKeystone (radians / m) = %f\n', params(6));
fprintf('\t zParallaxDeformation (m/m) = %f\n', params(7));
