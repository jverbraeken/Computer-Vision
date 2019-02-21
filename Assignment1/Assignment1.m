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

%% Exercise 5.5: Impulse response

sigma = 1;
length = 129;
med = ceil(length/2);
F = zeros(length, length);
F(med, med) = 1;
G = gaussian(sigma);

% Zero derivative: blurring
FF = conv2(G,G,F);
figure
subplot(2,3,1)
imshow(FF, []);
title('blur')

% First order derivative
FF = ImageDerivatives(F, sigma, 'x');
subplot(2,3,2);
imshow(FF, [])
title('x-der')

subplot(2,3,3); 
FF = ImageDerivatives(F, sigma, 'y');
imshow(FF, []);
title('y-der')

% Second order derivative
subplot(2,3,4);
FF = ImageDerivatives(F, sigma, 'xx');
imshow(FF, []);
title('xx-der')

subplot(2,3,5);
FF = ImageDerivatives(F, sigma, 'yy');
imshow(FF, []);
title('yy-der')

subplot(2,3,6);
FF = ImageDerivatives(F, sigma, 'xy');
imshow(FF, []);
title('xy-der');