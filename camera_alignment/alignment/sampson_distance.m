function d = sampson_distance(pts1h, F, pts2h)

pfp = (pts2h * F)';
pfp = pfp .* pts1h;
d = sum(pfp, 1) .^ 2;

% additional step for sampson distance
epl1 = F * pts1h;
epl2 = F' * pts2h';
d = d ./ (epl1(1,:).^2 + epl1(2,:).^2 + epl2(1,:).^2 + epl2(2,:).^2);

end
