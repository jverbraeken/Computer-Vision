% Final Project
addpath("../Assignment3");
addpath("../Assignment5");
addpath("../Assignment6");

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

% Lab assignment 6

disp("----");
%% 4th step: Stitch points together
disp("4th step: Stitch points together");

% TODO, depends on assignment 6
% M = ...
% S = ...
% save('M','M')

disp("----");
%% 5th step: Eliminate affine ambiguity
disp("5th step: Eliminate affine ambiguity");

% Eliminate the affine ambiguity
% Orthographic: We need to impose that image axes (a1 and a2) are perpendicular and their scale is 1.
% (a1: col vector, projection of x; a2: row vector, projection of y;,)
% We define the starting value for L, L0 as: A1 L0 A1' = Id 
A1 = M(1:2, :);
L0 = pinv(A1' * A1);

% We solve L by iterating through all images and finding L one which minimizes Ai*L*Ai' = Id, for all i.
% LSQNONLIN solves non-linear least squares problems. Please check the Matlab documentation.
L = lsqnonlin(@residuals, L0);

% Recover C from L by Cholesky decomposition.
C = chol(L,'lower');

% Update M and S with the corresponding C form: M = MC and S = C^{-1}S. 
M = M * C;
S = pinv(C) * S;

disp("----");
%% 6th step: Plot 3D model
disp("6th step: Plot 3D model");

plot3(S(1,:),S(2,:),S(3,:),'.r');

disp("----");