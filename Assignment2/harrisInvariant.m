function [r, c] = harrisInvariant(im, sigma)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

R = zeros(size(im,1), size(im,2), length(sigma));
Rdel = zeros(size(R));
for i=1:length(sigma)
    H = fspecial('laplacian');
    Il = sigma(i)^2 * imfilter(im, H);
    [~, ~, R(:,:,i)] = harris(Il, sigma(i));
    %Rdel(:,:,i) = imdilate(R(:,:,i), strel('square', 3));
end

% Set the threshold as a ratio of the max value
threshold = 0.001 * max(R, [], 'all');

%Rb = ones(size(im, 1), size(im, 2));
%for i = 1:length(sigma)
%    Rb = Rb & ((R(:,:,i) > threshold)); %& (Rdel(:,:,i) == R(:,:,i))) ; %.* sigma;
%end
Rb = R > threshold & (imdilate(R, strel('cube', 3)) == R);
Rb = bsxfun(@times, Rb, permute(sigma, [3, 1, 2]));
[r, c] = find(Rb);
imshow(Rb);
colorbar




end

