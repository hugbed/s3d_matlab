function F = denormalize_F(F, T, Tp)

F = Tp' * F * T;
F = F / F(3, 2);

end
