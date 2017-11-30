function [H, Hp] = compute_rectification(alignment, varargin)
   
ch_y = alignment(1);   % vertical
a_z = alignment(2);    % roll
a_f = alignment(3);    % zoom
f_a_x = alignment(4); % tiltOffset
a_y_f = alignment(5);  % panKeystone
a_x_f = alignment(6);  % tiltKeystone
ch_z_f = alignment(7); % zParallaxDeformation

% H = [1.0,    ch_y, 0.0;
%     -ch_y,   1.0,  0.0;
%     -ch_z_f, 0,    1.0]';
% 
% Hp = [1 - a_f,       a_z + ch_y,  0;
%      -(a_z + ch_y),  1 - a_f,    f_a_x;
%       a_y_f - 0.0,  -a_x_f,      1]';
  
% experiment here
H = [1.0,    ch_y, 0.0;
    -ch_y,   1.0,  0.0;
    -ch_z_f, 0,    1.0];

Hp = [1 - a_f,         a_z + ch_y,  0;
     -(a_z + ch_y),    1 - a_f,     f_a_x;
      a_y_f - ch_z_f, -a_x_f,       1];

H = H';
Hp = Hp';

% centered rectification
if nargin == 2
  T = varargin{1};
  H = decenter_rectification(H, T);
  Hp = decenter_rectification(Hp, T);
end

end

function H = decenter_rectification(H, T)
H = (inv(T) * H' * T)';
end
