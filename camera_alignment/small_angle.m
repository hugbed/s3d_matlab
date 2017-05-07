clear all;
close all;
clc;

syms a b g
Rx_a = [1  0  0
        0  1 -a
        0  a  1];
    
Ry_b = [1  0  b
        0  1  0
        -b 0  1];

Rz_g = [1 -g  0
        g  1  0
        0  0  1];
    
Rx_a*Ry_b*Rz_g


syms a_x a_y a_z c_x c_y c_z
R = [1   -a_z  a_y
     a_z  1   -a_x
    -a_y  a_x  1  ];

t = R*[c_x c_y c_z].'
