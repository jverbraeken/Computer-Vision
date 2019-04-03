function [Im] = imageParser(folder, filetype)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

files = dir(fullfile(folder, strcat('*.', filetype)));
im_name = fullfile(folder, files(1).name);
im = imread(im_name);
Im = zeros(size(im,1), size(im,2), 3, numel(files), 'uint8');
Im(:, :, :, 1) = im;
for i = 2:numel(files)
    im_name = fullfile(folder, files(i).name);
    Im(:, :, :, i) = imread(im_name);
end
