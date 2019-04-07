function [Im] = imageParser(folder, filetype)
    files = dir(fullfile(folder, strcat('*.', filetype)));
    im_name = fullfile(folder, files(1).name);
    im = imread(im_name);
    Im = zeros(size(im,1), size(im,2), numel(files), 'single');
    Im(:,:,1) = single(rgb2gray(im));
    for i = 2:numel(files)
        im_name = fullfile(folder, files(i).name);
        im = imread(im_name);
        Im(:,:,i) = single(rgb2gray(im));
    end
end
