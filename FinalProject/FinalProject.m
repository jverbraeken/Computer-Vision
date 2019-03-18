% Final Project

%% 0nd step: Read the images and resize
disp("0nd step: Read the images and resize");

I = imageParser('model_castle', 'JPG');
I = imresize(I, 0.5);  % Prevent Out-of-Memory exception

disp("----");
%% 1st step: Find correspondences between consecutive matching
disp("1st step: Find correspondences between consecutive matching");

ind = randi(size(I, 3), 1, 1);
ind2 = mod(ind-1, size(I, 3)) + 1;  % ind2 = (ind != size(I, 3)) ? ind : 1
dist_thres = 0.8;
edge_thres = 0.1;
mode = 'own';
[match1, match2] = findMatches(I(:, :, ind), I(:, :, ind2), dist_thres, edge_thres, mode);

disp("----");
%% 2nd step: Apply normalized 8-point RANSAC algorithm to find best matches
disp("2nd step: Apply normalized 8-point RANSAC algorithm to find best matches");
[F, inliers] = estimateFundamentalMatrix(X1,X2);

disp("----");
%% 3rd step: Represent point correspondes for different camera views
disp("3rd step: Represent point correspondes for different camera views");

disp("----");
%% 4th step: Stitch points together
disp("4th step: Stitch points together");

disp("----");
%% 5th step: Eliminate affine ambiguity
disp("5th step: Eliminate affine ambiguity");

disp("----");
%% 6th step: Plot 3D model
disp("6th step: Plot 3D model");

disp("----");