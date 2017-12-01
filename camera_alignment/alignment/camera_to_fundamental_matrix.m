function F = camera_to_fundamental_matrix(K1, K2, R, t)
  A = K1 * R' * t;
  C = [0    -A(3)  A(2);
       A(3)  0    -A(1);
      -A(2)  A(1)  0];
  F = (inv(K2))' * R * K1' * C;
end