%  Apply normalized 8-point RANSAC algorithm to find best matches
% Input:
%     -directory: where to load images
% Output:
%     -C: coordinates of interest points
%     -D: descriptors of interest points
%     -Matches:Matches (between each two consecutive pairs, including the last & first pair)

function [C, D, Matches] = ransac_match(directory, plotEpipolars)
    Files=dir(strcat(directory, '*.png'));
    n = length(Files);

    % Initialize coordinates C and descriptors D
    C ={};
    D ={};
    % Load all features (coordinates and descriptors of interest points)
    % As an example, we concatenate the haraff and hesaff sift features
    % You can also use features extracted from your own Harris function.
    for i = 1:n
        disp('image num');
        i
        [coord_haraff,desc_haraff,~,~] = loadFeatures(strcat(directory, Files(i).name, '.haraff.sift'));
        [coord_hesaff,desc_hesaff,~,~] = loadFeatures(strcat(directory, Files(i).name, '.hesaff.sift'));
        
        coord   = [coord_haraff coord_hesaff];
        desc    = [desc_haraff desc_hesaff];
        
        C{i} = coord(1:2, :);
        D{i} = desc;
    end

    % Initialize Matches (between each two consecutive pairs)
    Matches={};

    for i = 1:n
        
        
        next = mod(i, n) + 1;
                
        coord1 = C{i};
        desc1  = D{i};
        
        coord2 = C{next};
        desc2  = D{next};
        
        disp('Matching Descriptors'); drawnow('update')
        
        % Find matches according to extracted descriptors using vl_ubcmatch
        %match = vl_ubcmatch(desc1,  desc2);
        im1 = rgb2gray(imread(strcat(directory, Files(i).name)));
        im2 = rgb2gray(imread(strcat(directory, Files(next).name)));
        match = SIFTmatch(im1,im2,0.8);
        disp(strcat( int2str(size(match,2)), ' matches found'));drawnow('update')
        
        % Obatain X,Y coordinates of matches points
        match1 = coord1(:, match(1, :));
        match2 = coord2(:, match(2, :));
        
        % Find inliers using normalized 8-point RANSAC algorithm
        [F, inliers] = estimateFundamentalMatrix(match1,match2);
        
        if plotEpipolars
            img1 = rgb2gray(imread(strcat(directory, Files(i).name)));
            img2 = rgb2gray(imread(strcat(directory, Files(next).name)));
        
            displayF(F, inliers, match1, match2, img1, img2);
        end
        
        drawnow('update')
        Matches{i} = match(:,inliers);
        
    end

end