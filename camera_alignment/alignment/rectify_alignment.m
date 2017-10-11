function [img1_rectified, img2_rectified] = rectify_alignment(img1, img2, alignment)

[H, Hp] = compute_rectification(alignment);

% alternative without black borders
% [img1_rectified, img2_rectified] = rectifyStereoImages(img1, img2, projective2d(H), projective2d(Hp));

img1_rectified = rectify(img1, H);
img2_rectified = rectify(img2, Hp);

end
