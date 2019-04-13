% Final Project for Computer Vision
% Group 20
% April 2019, Delft

%% Step 0: parameter tuning for running the script

clear all;
close all;

% directories for loading images and exporting results
% uncomment the first for runnning the pipeline for the castle images and
% the second for the teddy images
%dir_data = './modelCastle_features/modelCastle_features/';
dir_data = 'TeddyBearPNG/';

% directory for storing temporary generated data (cache)
global dir_generated;
dir_generated = strcat('generated/', dir_data);

% set to true in case you want epipolar lines between consecutive images to
% be plotted
% WARNING: quite a lot images will be plotted! 
plotEpipolars = false;

% select the mode for feature detection and matching:
%   harris: own implemented Harris feature detection and matching
%   sift: using the vl_feat toolbox detection and matching
%   features: using supplied features and vl_feat for matching (USE THIS FOR GOOD RESULTS)
mode = 'harris';

Files=dir(strcat(dir_data, '*.png'));
%% Step 1-2: Matching
disp("1st step: Find correspondences between consecutive matching");

switch mode
    case 'harris'
        if exist(strcat(dir_generated, 'Matches_harris.mat')) && exist(strcat(dir_generated, 'C_harris.mat'))
            load(strcat(dir_generated, 'Matches_harris.mat'));
            load(strcat(dir_generated, 'C_harris.mat'));
        else
            [C, ~, matches] = harris_match(dir_data, plotEpipolars); 
            save(strcat(dir_generated, 'Matches_harris.mat'), 'matches');
            save(strcat(dir_generated, 'C_harris.mat'), 'C');
        end
    case 'sift'
        if exist(strcat(dir_generated, 'Matches_sift.mat')) && exist(strcat(dir_generated, 'C_sift.mat'))
            load(strcat(dir_generated, 'Matches_sift.mat'));
            load(strcat(dir_generated, 'C_sift.mat'));
        else
            [C, ~, matches] = sift_match(dir_data, plotEpipolars); 
            save(strcat(dir_generated, 'Matches_sift.mat'), 'matches');
            save(strcat(dir_generated, 'C_sift.mat'), 'C');
        end
    case 'features'
        if exist(strcat(dir_generated, 'Matches_features.mat')) && exist(strcat(dir_generated, 'C_features.mat'))
            load(strcat(dir_generated, 'Matches_features.mat'));
            load(strcat(dir_generated, 'C_features.mat'));
        else
            [C, ~, matches] = ransac_match(dir_data, plotEpipolars); 
            save(strcat(dir_generated, 'Matches_features.mat'), 'matches');
            save(strcat(dir_generated, 'C_features.mat'), 'C');
        end
    otherwise
        disp('Give a correct value: {"harris", "sift", "features"}')
end

disp('Finished 1st/2nd step')

%% Step 3: Chaining

disp('3rd step: Chaining')

PV = chainimages(matches);

disp('Finished 3rd step')

%% Step 4-5: Stitching & elimination of affine ambiguity 

disp('4th step: Stitching & elimination of affine ambiguity from sfm')

[mergedCloud, mainView, M1, MeanFrame1] = stitching(dir_data, PV, C);

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
axis([min(X) max(X) min(Y) max(Y) min(Z) max(Z)])
daspect([1 1 1])
rotate3d

disp('Finished 4th/5th step')

%% Step 6: 3D Surface rendering

disp('6th step: 3D Surface rendering')

mainImg = imread(strcat(dir_data, Files(mainView).name));
surfaceRender(mergedCloud, M1, MeanFrame1, mainImg);
