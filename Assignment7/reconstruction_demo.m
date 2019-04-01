% This function incorporates all the required steps for the final project. 
% Please pay attention to expected data formats and data sizes.

function [] = reconstruction_demo()

    % Open the specified folder and read images. 
    directory = './TeddyBearPNG/';  % Path to your local image directory 
    Files=dir(strcat(directory, '*.png'));
    n = length(Files);

    % Apply normalized 8-point RANSAC algorithm to find best matches. (Lab assignment 3+5)
    % The output includes cell arrays with Coordinates (C), Descriptors (D) and indies (Matches)for all matched pairs.
    disp('ransac_match');
    if exist(strcat(directory, 'Matches.mat')) && exist(strcat(directory, 'C.mat'))
        load(strcat(directory, 'Matches.mat'));
        load(strcat(directory, 'C.mat'));
    else
        [C, D, matches] = ransac_match(directory); 
        save(strcat(directory, 'Matches.mat'), 'matches');
        save(strcat(directory, 'C.mat'), 'C');
    end

    % Chaining: Create point-view matrix (PV) to represent point correspondences 
    % for different camera views (Lab assignment 6).
    disp('chainimages');
    if exist(strcat(directory, 'PV.mat'))
        load(strcat(directory, 'PV.mat'));
    else
        [PV] = chainimages(matches);
        save(strcat(directory, 'PV.mat'), 'PV');
    end


    % Stitching: with affine Structure from Motion
    % Stitch every 3 images together to create a point cloud.
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

    mergedCloud(3,:) = mergedCloud(3,:) * (-1);
    
    % Plot the full merged cloud
    % Helpful for debugging and visualizing your reconstruction
    X = mergedCloud(1,:)';
    Y = mergedCloud(2,:)';
    Z = mergedCloud(3,:)';
    scatter3(X, Y, Z, 20, [1 0 0], 'filled');
    axis( [-500 500 -500 500 -500 500] )
    daspect([1 1 1])
    rotate3d


    % You are free to use other techniques like (Bundle Adjustment) to further
    % improve your reconstruction.


    % 3D Model Plotting (surfaceRender):

    img1 = imread(strcat(directory, 'obj02_001.png'));
    surfaceRender(mergedCloud, M1, MeanFrame1, img1);  % TODO get image

    % When you have the 3D point cloud of the moodel, use the built-in surf
    % function for the 3D surface plot. Then include RGB (texture) colour of
    % the related points on surf visualization (interpolate colour values for
    % the filled areas on the surface using the known points). 
    % Students are supposed to implement this in a clever way (by using built-in
    % Matlab functions).

end
