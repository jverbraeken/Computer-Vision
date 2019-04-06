function [C, D, matches] = harris_match(directory)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Files=dir(strcat(directory, '*.png'));
n = length(Files);
plotEpipolars = false;

load('C_harris.mat');
load('D_harris.mat');

thres = 0.8;
%{
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
    loc1 = DoG(im, 0.01);
    [r1,c1,s1] = harris(im, loc1, thres);
    fc1 = [c1'; r1'; s1'; zeros(1, size(r1, 1))];
    [~, d1] = vl_sift(single(im), 'frames', fc1);
    C1 = [c1, r1]';
    C{i} = C1;
    D{i} = d1;
end
%}

for i = 1:n

    next = mod(i, n) + 1;
    
    coord1 = C{i};
    desc1  = D{i};

    coord2 = C{next};
    desc2  = D{next};

    disp('Matching Descriptors'); drawnow('update')

    % Find matches according to extracted descriptors using vl_ubcmatch
    match = SIFTmatch(desc1, desc2);
    disp(strcat( int2str(size(match,2)), ' matches found'));drawnow('update')

    % Obatain X,Y coordinates of matches points
    match1 = coord1(:, match(1, :));
    match2 = coord2(:, match(2, :));

    %{
    % Find inliers using normalized 8-point RANSAC algorithm
    
    [F, inliers] = estimateFundamentalMatrix(match1,match2);

    if plotEpipolars
        img1 = rgb2gray(imread(strcat(directory, Files(i).name)));
        img2 = rgb2gray(imread(strcat(directory, Files(next).name)));

        displayF(F, inliers, match1, match2, img1, img2);
    end
    %}

    drawnow('update')
    Matches{i} = match(:,inliers);

end




end

