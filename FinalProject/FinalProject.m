% Final Project
addpath(genpath("../Assignment2"));
addpath(genpath("../Assignment3"));
addpath(genpath("../Assignment5"));
addpath(genpath("../Assignment6"));
addpath(genpath("../Assignment7"));
addpath(genpath("../vlfeat-0.9.21"));

step1 = struct('haraff_hesaff', 1, 'library', 2, 'own', 3);

choice_step1 = step1.haraff_hesaff;
dir_generated = './generated/';
dir_features = './modelCastle_features/';


%% 0nd step: Read the images and resize
disp("0nd step: Read the images and resize");

[n, images] = step_0(dir_generated, dir_features);

disp("----");
%% 1st step: Find correspondences between consecutive matching
% 2nd step: Apply normalized 8-point RANSAC algorithm to find best matches
disp("1st step: Find correspondences between consecutive matching");

[C, matches] = step_1_2(step1, choice_step1, dir_generated, dir_features, n, images);

disp("----");
%% 3rd step: Represent point correspondes for different camera views
disp("3rd step: Represent point correspondes for different camera views");

PV = step_3(matches);

disp("----");
%% 4th step: Stitch points together
disp("4th step: Stitch points together");

mergedCloud = step_4(PV, n, C, dir_generated);

disp("----");
%% 5th step: Eliminate affine ambiguity
disp("5th step: Eliminate affine ambiguity");

% Is this needed? Already done in sfm...

% Eliminate the affine ambiguity
% Orthographic: We need to impose that image axes (a1 and a2) are perpendicular and their scale is 1.
% (a1: col vector, projection of x; a2: row vector, projection of y;,)
% We define the starting value for L, L0 as: A1 L0 A1' = Id 
% A1 = M(1:2, :);
% L0 = pinv(A1' * A1);

% We solve L by iterating through all images and finding L one which minimizes Ai*L*Ai' = Id, for all i.
% LSQNONLIN solves non-linear least squares problems. Please check the Matlab documentation.
% L = lsqnonlin(@residuals, L0);

% Recover C from L by Cholesky decomposition.
% C = chol(L,'lower');

% Update M and S with the corresponding C form: M = MC and S = C^{-1}S. 
% M = M * C;
% S = pinv(C) * S;

disp("----");
%% 6th step: Plot 3D model
disp("6th step: Plot 3D model");

step_6(mergedCloud);

disp("----");