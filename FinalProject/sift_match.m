function [C, D , Matches] = sift_match(directory, plotEpipolars)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

Files=dir(strcat(directory, '*.png'));
n = length(Files);

C = {};
D = {};
for i=1:n 
    disp('image num');
    i
    im = single(rgb2gray(imread(strcat(directory, Files(i).name))));
    [coord, desc] = vl_sift(im); 
    C{i} = coord(1:2, :);
    D{i} = desc;
end

for i = 1:n
   
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

