% Final Project for Computer Vision
% April 2019, Delft
% Author: Ioannis Lelekas

%% Step 0: parameter tuning for running the script

clear all
close all

% directories for loading images and exporting results
% uncomment the first for runnning the pipeline for the castle images and
% the second for the teddy images
%directory = './modelCastle_features/modelCastle_features/';
directory = './TeddyBearPNG/';

% set to true in case you want epipolar lines between consecutive images to
% be plotted
% WARNING: quite a lot images will be plotted! 
plotEpipolars = true;

% select the mode for feature detection and matching:
% harrris: own implemented Harris feature detection and matching
% sift: using the vl_feat toolbox detection and matching
% features: using supplied features and vl_feat for matching (USE THIS FOR GOOD RESULTS)
mode = 'harris';

Files=dir(strcat(directory, '*.png'));
%% Step 1-2: Matching
disp("1st step: Find correspondences between consecutive matching");

switch mode
    case 'harris'
        if exist(strcat(directory, 'Matches_harris.mat')) && exist(strcat(directory, 'C_harris.mat'))
            load(strcat(directory, 'Matches_harris.mat'));
            load(strcat(directory, 'C_harris.mat'));
        else
            [C, ~, matches] = harris_match(directory, plotEpipolars); 
            save(strcat(directory, 'Matches_harris.mat'), 'matches');
            save(strcat(directory, 'C_harris.mat'), 'C');
        end
    case 'sift'
        if exist(strcat(directory, 'Matches_sift.mat')) && exist(strcat(directory, 'C_sift.mat'))
            load(strcat(directory, 'Matches_sift.mat'));
            load(strcat(directory, 'C_sift.mat'));
        else
            [C, ~, matches] = sift_match(directory, plotEpipolars); 
            save(strcat(directory, 'Matches_sift.mat'), 'matches');
            save(strcat(directory, 'C_sift.mat'), 'C');
        end
    case 'features'
        if exist(strcat(directory, 'Matches_features.mat')) && exist(strcat(directory, 'C_features.mat'))
            load(strcat(directory, 'Matches_features.mat'));
            load(strcat(directory, 'C_features.mat'));
        else
            [C, ~, matches] = ransac_match(directory, plotEpipolars); 
            save(strcat(directory, 'Matches_features.mat'), 'matches');
            save(strcat(directory, 'C_features.mat'), 'C');
        end
    otherwise
        disp('Give a correct value: {"harris", "sift", "features"}')
end
    
%% Step 3: Chaining

disp('3rd step: Chaining')

PV = chainimages(matches);

%% Step 4-5: Stitching & elimination of affine ambiguity 

disp('4th step: Stitching & elimination of affine ambiguity from sfm')

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
axis( [-1500 1500 -1500 1500 -1500 1500] )
daspect([1 1 1])
rotate3d

%% Step 6: 3D Surface rendering

disp('6th step: 3D Surface rendering')

% reversing the cloud
%mergedCloud(3,:) = mergedCloud(3,:) * (-1);

mainImg = imread(strcat(directory, Files(mainView).name));
surfaceRender(mergedCloud, M1, MeanFrame1, mainImg);
