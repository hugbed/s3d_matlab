syms f cy cz f_l f_r ax ay az af rx ry rz w h

f_l = f;
f_r = f_l/(1-af)

% rectification left
K_ol = [f_l,  0,   0;
        0,    f_l, 0;
        0     0    1];

% left zoom should stay the same
K_nl = K_ol;

% right initial zoom may be different
K_or = [f_r,  0,   0;
        0,    f_r, 0;
        0     0    1];
K_or = K_ol;
    
% but right new zoom should be equal as left old zoom    
K_nr = K_ol;

% left rotation (y-shift, z-parallax)
R_l = [1,  -cy, cz;
       cy,  1,  0;
      -cz,  0   1];

% right rotation
rx = ax;
ry = ay + cz;
rz = az + cy;

R_r = [1,  -rz,  ry;
       rz,  1,  -rx;
      -ry,  rx,  1];
  
% rectification matrices
H_l = K_nl * R_l.' * inv(K_ol)
H_r = K_nr * R_r.' * inv(K_or)
