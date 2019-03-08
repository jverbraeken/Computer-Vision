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
        [affine, ~, ~] = imageAlign(imtarget, imnew);
	
        affine = invert(affine);
        % Define the transformation matrix from 'best_h' (best affine parameters) 	
        A(:,:,i) = (affine.T)';
        
        % Combine the affine transformation with all previous matrices
        % to get the transformation to the first image
        accA(:,:,i) = A(:,:,i) * accA(:,:,i-1);
    
        % Add the corners of this image
        w = size(imnew,2);
        h = size(imnew,1);
        corners = [corners; (accA(:,:,i))*[1 1 1; w 1 1; 1 h 1; w h 1]'];
    end

    % Find size of output image
    minx = ceil(min(corners(1:3:end, :), [], 2));
    maxx = ceil(max(corners(1:3:end, :), [], 2));
    miny = ceil(min(corners(2:3:end, :), [], 2));
    maxy = ceil(max(corners(2:3:end, :), [], 2));
    
    % Output image coordinate system
    xdata = [min(minx), max(maxx)];
    ydata = [min(miny), max(maxy)];

    % Output image
    imgout = zeros(max(maxy) - min(miny) + 1, max(maxx) - min(minx) +1, nargin);
    
    % Transform each image to the coordinate system
    for i=1:nargin
        tform         = affine2d([A(:,1,i)'; A(:,2,i)'; A(:,3,i)']);
        imtarget      = varargin{i};    
        newtimg       = imwarp(imtarget, tform, 'bicubic');
        newtimg       = padarray(newtimg, [miny(i) - 1, minx(i) - 1], 'pre');
        newtimg       = padarray(newtimg, [size(imgout, 1) - size(newtimg, 1), size(imgout, 2) - size(newtimg, 2)], 'post');
        
        imgout(:,:,i) = newtimg;
    end

    % Blending methods to combine: nanmedian (stable for longer sequences of images)
    imgout(imgout == 0) = NaN;
    imgout = nanmean(imgout, 3);

    % Show stitched image
    RA = imref2d(size(imgout), xdata, ydata);
    figure; imshow(imgout, RA, []);
    
end
