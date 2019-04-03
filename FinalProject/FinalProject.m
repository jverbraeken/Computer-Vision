% Final Project
addpath(genpath("../Assignment3"));
addpath(genpath("../Assignment5"));
addpath(genpath("../Assignment6"));
addpath(genpath("../Assignment7"));
addpath(genpath("../vlfeat-0.9.21"));

%% 0nd step: Read the images and resize
disp("0nd step: Read the images and resize");

I = imageParser('model_castle', 'JPG');
% I = imresize(I, 0.5);  % Prevent Out-of-Memory exception

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
[F, inliers] = estimateFundamentalMatrix(match1(1:2, :), match2(1:2, :));
Matches{i} = match(:,inliers);

disp("----");   
%% 3rd step: Represent point correspondes for different camera views
disp("3rd step: Represent point correspondes for different camera views");

if exist(strcat(directory, 'PVfinal.mat'))
    load(strcat(directory, 'PVfinal.mat'));
else
    [PV] = chainimages(matches);
    save(strcat(directory, 'PVfinal.mat'), 'PVfinal');
end

disp("----");
%% 4th step: Stitch points together
disp("4th step: Stitch points together");

Clouds = {};
i = 1;
numFrames=3;

for iBegin = 1:n
    iEnd = mod(iBegin + 2, n); 

    % Select frames from the PV matrix to form a block
    if iBegin < iEnd
        ind = iBegin:iEnd;
    else
        ind = [iBegin:n 1:iEnd];
    end
    block = PV(ind, :);

    % Select columns from the block that do not have any zeros
    zeroInds = block ~= 0;
    colInds = find(zeroInds(1, :) .* zeroInds(2, :) .* zeroInds(3, :));

    % Check the number of visible points in all views
    numPoints = length(colInds);
    if numPoints < 8
        continue
    end


    % Create measurement matrix X with coordinates instead of indices using the block and the 
    % Coordinates C 
    block = block(:, colInds);
    X = zeros(2 * numFrames, numPoints);
    for f = 1:numFrames    
        coord = C{ind(f)};
        X(2 * f - 1, :) = coord(1, block(f, :));
        X(2 * f, :)     = coord(2, block(f, :));
    end

    save(strcat(directory, 'X.mat'), 'X');

    % Estimate 3D coordinates of each block following Lab 4 "Structure from Motion" to compute the M and S matrix.
    % Here, an additional output "p" is added to deal with the non-positive matrix error
    % Please check the chol function inside sfm.m for detail.
    [M, S, p] = sfm(directory);     % Your structure from motion implementation for the measurements X

    if i == 1 && ~p
        M1 = M(1:2, :);
        MeanFrame1 = sum(X, 2) / numPoints;
    end
    if ~p
        % Compose Clouds in the form of (M,S,colInds)
        Clouds(i, :) = {M, S, colInds};
        i = i + 1;
    end
end

% By an iterative manner, stitch each 3D point set to the main view using the point correspondences i.e., finding optimal
% transformation between shared points in your 3D point clouds. 

% Initialize the merged (aligned) cloud with the main view, in the first point set.
mergedCloud                 = zeros(3, size(PV,2));
mergedCloud(:, Clouds{1,3}) = Clouds{1, 2};  
mergedInds                  = Clouds{1, 3};

% Stitch each 3D point set to the main view using procrustes
numClouds = size(Clouds,1);
for i = 2:numClouds

    newCloudInds = Clouds{i, 3};
    % Get the points that are in the merged cloud and the new cloud by using "intersect" over indexes
    [sharedInds, ~, IB] = intersect(mergedInds, newCloudInds);
    sharedPoints = Clouds{i, 2}(:, IB);

    % A certain number of shared points to do procrustes analysis.
    if size(sharedPoints, 2) < 15
        continue
    end

    % Find optimal transformation between shared points using procrustes
    [~, ~, T] = procrustes(mergedCloud(:, sharedInds)', sharedPoints');

    % Find the points that are not shared between the merged cloud and the Clouds{i,:} using "setdiff" over indexes
    [iNew, iCloudsNew] = setdiff(newCloudInds, mergedInds);

    % T.c is a repeated 3D offset, so resample it to have the correct size
    T.c = T.c(ones(size(iCloudsNew,1),1),:);
    %T.c = T.c(:, ones(size(iCloudsNew,1),1));

    % Transform the new points using: Z = T.b * T * T.T + T.c.
    % and store them in the merged cloud, and add their indexes to merged set
    mergedCloud(:, iNew) = T.b * T.T' * Clouds{i, 2}(:, iCloudsNew) + T.c';
    mergedInds           = [mergedInds iNew];
end

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