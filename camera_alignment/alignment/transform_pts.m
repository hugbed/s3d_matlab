function pts_transformed = transform_pts(pts, T)

N = size(pts, 1);
pts_H = (T*[pts ones(N, 1)]')';
pts_transformed = pts_H(:, 1:2);

end