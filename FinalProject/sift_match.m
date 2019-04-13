function [C, D , Matches] = sift_match(directory, plotEpipolars)
    % % Input:
    %     -directory: where to load images
    %     -plotEpipolars: binary parameter whether figures with epipolar lines
    %     will be created
    % Output:
    %     -C: coordinates of interest points
    %     -D: descriptors of interest points
    %     -Matches:Matches (between each two consecutive pairs, including the last & first pair)
    %  Performs feature detection and correspondence matches by using the
    %  vl_feat toolbox. Apply normalized 8-point RANSAC algorithm to find best matches

    Files=dir(strcat(directory, '*.png'));
    n = length(Files);

    C = {};
    D = {};
    
    parfor i=1:n
        disp(strcat('image num: ', num2str(i)));
        im = rgb2gray(imread(strcat(directory, Files(i).name)));
        se = strel('disk', 1, 4);
        morph_grad = imsubtract(imdilate(im, se), imerode(im, se));
        mask = im2bw(morph_grad, 0.03);
        se = strel('disk', 3, 4);
        mask = imclose(mask, se);
        mask = imfill(mask, 'holes');
        mask = bwareafilt(mask, 1);
        not_mask = ~mask;
        mask = mask | bwpropfilt(not_mask, 'area', [-Inf, 1000 - eps(1000)]);
        se = strel('disk', 30);
        mask = imclose(mask, se);
        mask = imfill(mask, 'holes');
        im(~mask) = 0;
        [coord, desc] = vl_sift(single(im));
        C{i} = coord(1:2, :);
        D{i} = desc;
    end

    parfor i = 1:n
        next = mod(i, n) + 1;

        coord1 = C{i};
        desc1  = D{i};

        coord2 = C{next};
        desc2  = D{next};

        disp('Matching Descriptors'); drawnow('update')
        disp('image num');
        i

        % Find matches according to extracted descriptors using vl_ubcmatch
        match = vl_ubcmatch(desc1,  desc2);
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
