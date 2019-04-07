function [C, D, Matches] = harris_match(directory, plotEpipolars)
% Input:
%     -directory: where to load images
%     -plotEpipolars: binary parameter whether figures with epipolar lines
%     will be created
% Output:
%     -C: coordinates of interest points
%     -D: descriptors of interest points
%     -Matches:Matches (between each two consecutive pairs, including the last & first pair)
% Performs feature detection and correspondence matching by using owr own 
% implementation of Harris corner detection and matching respectively. 
% Apply normalized 8-point RANSAC algorithm to find best matches

Files=dir(strcat(directory, '*.png'));
n = length(Files);

load('C_harris.mat');
load('D_harris.mat');

thres = 0.8;

C ={};
D ={};
% Load all features (coordinates and descriptors of interest points)
% As an example, we concatenate the haraff and hesaff sift features
% You can also use features extracted from your own Harris function.
for i = 1:n
    disp('image num');
    i
     % Find features and make descriptor of image 1 2
    im = rgb2gray(imread(strcat(directory, Files(i).name)));
    loc = DoG(im, 0.001);
    [row, col, scale] = harris(im, loc, thres);
    frames = [col'; row'; scale'; zeros(1, size(row, 1))];
    [~, desc] = vl_sift(single(im), 'frames', frames);
    feat = [col, row, scale]';
    C{i} = feat;
    D{i} = desc;
end


Matches = {};

for i = 1:n

    next = mod(i, n) + 1;
    
    coord1 = C{i}(1:2, :);
    desc1  = D{i};

    coord2 = C{next}(1:2, :);
    desc2  = D{next};

    disp('Matching Descriptors'); drawnow('update')
    disp('image num');
    i

    % Find matches according to extracted descriptors using vl_ubcmatch
    match = findMatches(desc1, desc2);
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

