Roll angle constant at 0 rad.
400 iterations.
40% outliers.
Robust estimator: LMedS

-- Image --
width = 512;
height = 512;

-- Camera --
f = 703;
field_of_view_deg = 2 * rad2deg(atan(height/2/f));
aspect_ratio = 1.5; % it is assumed it is 1.0

C = [f, 0.0,              width / 2;
     0, aspect_ratio * f, height / 2;
     0, 0.0,              1.0] / f;

baseline = 0.5
feature point noise std = 2 pixels

-- filter --

Q = all zeros

R trained on random 400 with rectified state.

noise on u = 0;