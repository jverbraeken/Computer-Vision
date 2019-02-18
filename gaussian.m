%% Assignment 1

%% Exercise 1

function G = gaussian(sigma)
    G  = zeros(3*sigma, 1);
    med = round(length(G)/2);
    
    y = 1:length(G);
    x = abs(med - y);
    G = exp(-x.^2/(2*sigma^2)) * (1/(sqrt(sigma*2*pi)));
   
end

%% Exercise 2

function imOut = gaussianConv(image_path, sigma_x, sigma_y)
    originalRGB = imread('zebra.png');
    img_x = imfilter(originalRGB, G);
    img_y = imfilter(img_x, G);
    imshow(img_y)
end
