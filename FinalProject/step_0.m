function [n, images] = step_0(dir_generated, dir_features)
    cache_name = strcat(dir_generated, 'images.mat');
    if exist(cache_name)
        load(cache_name);
    else
        images = imageParser(dir_features, 'png');
        images = imresize(images, 0.35);  % Prevent Out-of-Memory exception
        save(cache_name, 'images');
    end
    n = size(images, 4);
end

