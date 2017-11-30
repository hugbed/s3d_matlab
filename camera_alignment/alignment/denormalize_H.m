function H = denormalize_H(H, T, Tp)

H = (inv(Tp) * H' * T)';

end
