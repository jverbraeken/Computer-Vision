function [r, c, R] = harris(im, sigma)
% inputs: 
% im: double grayscale image
% sigma: integration-scale
% outputs:  The row and column of each point is returned in r and c
% This function finds Harris corners at integration-scale sigma.
% The derivative-scale is chosen automatically as gamma*sigma

gamma = 0.7; % The derivative-scale is gamma times the integration scale

% Calculate Gaussian Derivatives at derivative-scale
% Hint: use your previously implemented function in assignment 1 
G = gaussian(sigma);
Gx = gaussianDer(G,sigma);
Ix =  conv2(im, Gx, 'same');
Iy =  conv2(im, Gx', 'same');

% Allocate an 3-channel image to hold the 3 parameters for each pixel
M = zeros(size(Ix,1), size(Ix,2), 3);

% Calculate M for each pixel
M(:,:,1) = Ix .^ 2;
M(:,:,2) = Iy .^ 2;
M(:,:,3) = Ix .* Iy;

% Smooth M with a gaussian at the integration scale sigma.
M = imfilter(M, fspecial('gaussian', ceil(sigma*6+1), sigma), 'replicate', 'same');

% Compute the cornerness R
k = 0.04;   %empirical constant
trace = M(:,:,1) + M(:,:,2);
det = M(:,:,1) .* M(:,:,2) - M(:,:,3).^2;
R = det - k*trace.^2;
imshow(R,[])

% Set the threshold as a ratio of the max value
threshold = 0.01 * max(R, [], 'all');

% Find local maxima
% Dilation will alter every pixel except local maxima in a 3x3 square area.
% Also checks if R is above threshold
Rb = ((R>threshold) & ((imdilate(R, strel('square', 3))==R))) ; %.* sigma;

% Display corners
figure
imshow(Rb,[]);

% Return the coordinates
[r,c] = find(Rb);

end
