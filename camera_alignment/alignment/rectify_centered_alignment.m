function [img1_rectified, img2_rectified] = rectify_centered_alignment(img1, img2, alignment, T, Tp)
% T, Tp: transform pre-applied on pts to compute alignment

[H, Hp] = compute_rectification(alignment);

H = denormalize_H(H, T, Tp)
Hp = denormalize_H(Hp, T, Tp)

% alternative without black borders
% [img1_rectified, img2_rectified] = rectifyStereoImages(img1, img2, projective2d(H), projective2d(Hp));

img1_rectified = rectify(img1, H);
img2_rectified = rectify(img2, Hp);

end
