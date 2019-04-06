% Final Project for Computer Vision
% April 2019, Delft
% Author: Ioannis Lelekas

clear all
close all

% directories for loading images and exporting results
% uncomment the first for runnning the pipeline for the castle images and
% the second for the teddy images

directory = './modelCastle_features/modelCastle_features/';
%directory = './TeddyBearPNG/';

Files=dir(strcat(directory, '*.png'));
%% 0nd step: Read the images and resize
disp("0nd step: Read the images and resize");

I = imageParser('model_castle', 'JPG');
I = imresize(I, 0.5);  % Prevent Out-of-Memory exception

disp("----");
%% Step 1-2: Matching
disp("1st step: Find correspondences between consecutive matching");

% Set to true if you want the epipolar lines between pairs of images to be
% plotted
plotEpipolars = false;

disp('ransac_match');
    if exist(strcat(directory, 'Matches.mat')) && exist(strcat(directory, 'C.mat'))
        load(strcat(directory, 'Matches.mat'));
        load(strcat(directory, 'C.mat'));
    else
        [C, ~, matches] = ransac_match(directory, plotEpipolars); 
        save(strcat(directory, 'Matches.mat'), 'matches');
        save(strcat(directory, 'C.mat'), 'C');
    end
    
%% Step 3: Chaining

disp('3rd step: Chaining')

if exist(strcat(directory, 'PV.mat'))
    load(strcat(directory, 'PV.mat'));
else
    [PV] = chainimages(matches);
    save(strcat(directory, 'PV.mat'), 'PV');
end

%% Step 4-5: Stitching & elimination of affine ambiguity 

disp('4th step: Stitching')

[mergedCloud, mainView, M1, MeanFrame1] = stitching(directory, PV, C);

% Plot the full merged cloud
    % Helpful for debugging and visualizing your reconstruction
    X = mergedCloud(1,:)';
    Y = mergedCloud(2,:)';
    Z = mergedCloud(3,:)';
    figure
    scatter3(X, Y, Z, 20, [1 0 0], 'filled');
    xlabel('x-axis')
    ylabel('y-label')
    zlabel('z-axis')
    axis( [-1000 1000 -1000 1000 -1000 1000] )
    daspect([1 1 1])
    rotate3d

%% Step 6: 3D Surface rendering

disp('6th step: 3D Surface rendering')

mergedCloud(3,:) = mergedCloud(3,:) * (-1);
mainImg = imread(strcat(directory, Files(mainView).name));
surfaceRender(mergedCloud, M1, MeanFrame1, mainImg);
