%% Assignment 1, Exercise 2

function imOut = gaussianConv(image_path, sigma_x, sigma_y)
    im = rgb2gray(imread(image_path));
    imOut = conv2(gaussianImpl(sigma_x), gaussianImpl(sigma_y), im, 'same');
    imshow(imOut, []);
end