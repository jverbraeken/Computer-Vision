% (1) Align two images using the Harris corner point detection and the sift match function.
% (2) Use RANSAC to get the affine transformation
% Input:
%       im1 - first image
%       im2 - second image
% Output:
%       affine_transform - the learned transformation between image 1 and image 2
%       match1           - the corner points in image 1
%       match2           - their corresponding matches in image 2
function [affine_transform, match1, match2] = imageAlign(im1, im2)

    % Load Images
    %im1 = im2double(imread('boat/img1.pgm'));
    %im2 = im2double(imread('boat/img2.pgm'));

    tf = 0.01;
    thres = 0.2;
    
    %{
    % Detect interest points using your own Harris implementation (lab 2).
    loc1 = DoG(im1, tf);
    [r1, c1, sigma1]       = harris(im1, loc1, thres);
    [frames1, descriptor1] = vl_sift(single(im1), 'frames', [c1'; r1'; sigma1'; zeros(1, length(r1))]);

    loc2 = DoG(im2, tf);
    [r2, c2, sigma2]       = harris(im2, loc2);
    [frames2, descriptor2] = sift(single(im2), 'frames', [c2', r2', sigma2', zeros(1, length(r2))]);
    %}

    % Get the set of possible matches between descriptors from two image.
    %matches = SIFTmatch(im1, im2, tf, thres); % Your lab 2 implementation for finding matches

    % Optional: You can compare with your results with the custom sift implementation 
    [feat1, descriptor1] = vl_sift(single(im1));
    [feat2, descriptor2] = vl_sift(single(im2));
    matches = vl_ubcmatch(descriptor1, descriptor2);
    % Note: In the final project you will be graded for having your own implementation 
    % for the Harris corner point detection and SIFT feature matching". 

    % Find affine transformation using your own Ransac function
    match1 = feat1(1:2,matches(1,:));
    match2 = feat2(1:2,matches(2,:));
    best_h = ransac_affine(match1, match2, im1, im2);

    % Draw both original images with the other image transformed to the first
    % image below it
    figure;
    subplot(2,2,1); imshow(im1, []); title('Original Image 1');
    subplot(2,2,2); imshow(im2, []); title('Original Image 2');

    % Define the transformation matrix from 'best_h' (best affine parameters) 
    affine_transform = affine2d([best_h(1) best_h(3) 0; best_h(2) best_h(4) 0 ;...
        best_h(5) best_h(6) 1]);

    % First image transformed
    im1b = imwarp(im1, affine_transform, 'bicubic');
    subplot(2,2,4); imshow(im1b, []); title('Image 1 transformed to image 2')

    % Second image transformed
    im2b = imwarp(im2, invert(affine_transform), 'bicubic'); 
    subplot(2,2,3); imshow(im2b, []); title('Image 2 transformed to image 1')
end
