% Stitch multiple images in sequence
% Can be used as mosaic(im1,im2,im3,...);
% Input:
%       varargin - sequence of images to stitch
% Output:
%       imgout - stitched images
function imgout = mosaic(varargin)

    % Begin with first image
    imtarget = varargin{1};

    % Find the image corners
    w = size(imtarget,2);
    h = size(imtarget,1);
    corners = [1 1 1; w 1 1; 1 h 1; w h 1]';

    % First image is not transformed
    A        = zeros(3, 3, nargin);
    A(:,:,1) = eye(3);
    accA     = A;

    % For all other images
    for i = 2:nargin
        % Load next image
        imnew = varargin{i};
    
        % Get transformation of this new image to previous image
        [~, best_h, ~, ~] = imageAlign(imtarget, imnew);
	
        % Define the transformation matrix from 'best_h' (best affine parameters) 	
        A(:,:,i) = [best_h(1) best_h(2) best_h(5);...
            best_h(3) best_h(4) best_h(6); 0 0 1];
    
        % Combine the affine transformation with all previous matrices
        % to get the transformation to the first image
        accA(:,:,i) = A(:,:,i) * accA(:,:,i-1);
    
        % Add the corners of this image
        w = size(imnew,2);
        h = size(imnew,1);
        corners = [corners (accA(:,:,i))*[1 1 1; w 1 1; 1 h 1; w h 1]'];
    end

    % Find size of output image
    minx = 1;
    maxx = ceil(max(corners(2, :)));
    miny = 1;
    maxy = ceil(max(corners(1, :)));

    % Output image
    imgout = zeros(maxy-miny+1, maxx-minx+1, nargin);

    % Output image coordinate system
    xdata = [minx, maxx];
    ydata = [miny, maxy];

    % Transform each image to the coordinate system
    for i=1:nargin
        tform         = affine2d([A(:,1,i); A(:,2,i); A(:,3,i)]);
        newtimg       = imtransform(varargin{i}, tform, 'bicubic');
        imgout(:,:,i) = newtimg;
    end

    % Blending methods to combine: nanmedian (stable for longer sequences of images)
    imgout = nanmean(imgout, 3);

    % Show stitched image
    figure; imshow(imgout);
    
end
