% Assignment 3
im1 = single(imread('boat/boat/img1.pgm'));
im2 = single(imread('boat/boat/img2.pgm'));

[frames1, desc1] = vl_sift(im1, 'PeakThresh', 20);
[frames2, desc2] = vl_sift(im2, 'PeakThresh', 20);

matches = vl_ubcmatch(desc1, desc2);

% 3 matches required to solve the affine matching;
P = 10;   
perm = randperm(length(matches), P);

% Construct matrix A and b
A = zeros(2*P, 6);
b = zeros(2*P, 1);
for i= 1:P
    p = [frames1(2, matches(1, perm(i))), frames1(1, matches(1, perm(i))), 0, 0, 1, 0; ...
        0, 0, frames1(2, matches(1, perm(i))), frames1(1, matches(1, perm(i))), 0, 1];
    A(i:i+1, :) = p;
    b(i:i+1) = [frames2(2, matches(2, perm(i))), frames2(1, matches(2, perm(i)))];
end

% Solve the linear system of equations to obtain the affine parameters
h = pinv(A) * b;

% Applying the affine transformation
tform = affine2d([h(1) h(3) 0; h(2) h(4) 0; h(5) h(6) 1]);
[x_prime, y_prime] = transformPointsForward(tform, frames1(2, matches(1, :)), frames1(1, matches(1, :)));

%% Visualize matching of original and transformed points

figure
imshow([im1 im2], [])
for i = 1:length(matches)
    viscircles([frames1(2, matches(1, i)), frames1(1, matches(1, i))], frames1(3, matches(1, i)));
    viscircles([x_prime(i) + size(im1, 2), y_prime(i)], frames2(3, matches(2, i)));
    line([frames1(2, matches(1, i)), size(im1, 2) + x_prime(i)], ...
        [frames1(1, matches(1, i)), y_prime(i)], 'Color', 'green');
end

%% Now use all points
A = zeros(2*length(matches), 6);
for i= 1:length(matches)
    p = [frames1(2, matches(1, i)), frames1(1, matches(1, i)), 0, 0, 1, 0; ...
        0, 0, frames1(2, matches(1, i)), frames1(1, matches(1, i)), 0, 1];
    A(i:i+1, :) = p;
end

% Recompute b based on augmented A
b_prime = A * h;

%% Find inliers
threshold = 10;
inliers = find(sqrt((x_prime - frames2(2, matches(2, :))).^2 + (y_prime - frames2(1, matches(2, :))).^2));

%% Visualize matching

figure
imshow([im1 im2], [])
for i = 1:length(matches)
    viscircles([frames1(2, matches(1, i)), frames1(1, matches(1, i))], frames1(3, matches(1, i)));
    viscircles([frames2(2, matches(2, i)) + size(im1, 2), frames2(1, matches(2, i))], frames2(3, matches(2, i)));
    line([frames1(2, matches(1, i)), size(im1, 2) + frames2(2, matches(2, i))], ...
        [frames1(1, matches(1, i)), frames2(1, matches(2, i))], 'Color', 'green');
end


%% Comparison with our own SIFTmatch

SIFTmatch(im1, im2, 0.01, 0.2);