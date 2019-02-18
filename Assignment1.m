%% Exercise 3: Comparison with Matlab functions

sigma = 1;
n = 3*sigma;
G=fspecial('gaussian',n,sigma);
im = rgb2gray(imread('zebra.png'));
imOut = conv2(im,G,'same');

imOut2 =  gaussianConv('zebra.png', sigma, sigma);

l2normdiff = sum(sqrt(sum((imOut - imOut2).^2, 2)));
imshow(imOut - imOut2, []);

%% Exercise 5.3: Thresholding magnitude and orientation of gradient

sigma = 1;
threshold = 20;
[magnitude, ~] = gradmag(im, sigma); 

figure
imshow(magnitude > threshold)
