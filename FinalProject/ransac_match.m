function [C, D, Matches] = ransac_match(directory, plotEpipolars)
% % Input:
%     -directory: where to load images
%     -plotEpipolars: binary parameter whether figures with epipolar lines
%     will be created
% Output:
%     -C: coordinates of interest points
%     -D: descriptors of interest points
%     -Matches:Matches (between each two consecutive pairs, including the last & first pair)
%  Apply normalized 8-point RANSAC algorithm to find best matches


    Files=dir(strcat(directory, '*.png'));
    n = length(Files);

    % Initialize coordinates C and descriptors D
    C ={};
    D ={};
    % Load all features (coordinates and descriptors of interest points)
    % As an example, we concatenate the haraff and hesaff sift features
    % You can also use features extracted from your own Harris function.
    parfor i = 1:n
        disp(strcat('image num: ', num2str(i)));
        [coord_haraff,desc_haraff,~,~] = loadFeatures(strcat(directory, Files(i).name, '.haraff.sift'));
        [coord_hesaff,desc_hesaff,~,~] = loadFeatures(strcat(directory, Files(i).name, '.hesaff.sift'));
        
        coord   = [coord_haraff coord_hesaff];
        desc    = [desc_haraff desc_hesaff];
        
        C{i} = coord(1:2, :);
        D{i} = desc;
    end

    % Initialize Matches (between each two consecutive pairs)
    Matches={};

    parfor i = 1:n
        next = mod(i, n) + 1;
                
        coord1 = C{i};
        desc1  = D{i};
        
        coord2 = C{next};
        desc2  = D{next};
        
        disp('Matching Descriptors'); drawnow('update')
        disp(strcat('image num: ', num2str(i)));
        
        % Find matches according to extracted descriptors using vl_ubcmatch
        match = ubcmatch(desc1,  desc2);
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
