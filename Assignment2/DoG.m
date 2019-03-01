%function loc = DoG(im,tf)
% uses the difference of gaussian approximation of a Lapalcian for finding 
% the scale of the local feature points.
%
%INPUT
%   -im: image (grayscale)
%   -tf: flatness threshold (typically 0.01)
%
%OUTPUT
%   -loc: a matrix of nx3 with n found locations with [y,x,sigma] for columns
function loc = DoG(im,tf)
    im = rgb2gray(im);
    loc = [];

    % Prior smoothing sigma
    sigmaP = 1.6;
    levels = 3;
    
    % Scaling factor
    k = 2^(1/levels);
    noCascades = 4;

    GP = cell(levels+3,1);
    for i = 1:levels+3
        GP{i} = gaussian( sigmaP*(k^(i-2)) ); % TODO: you could use your own 
    end
    im2 = imresize(im,2);

    % For all octaves
    for cascade = 1:noCascades
        % Gaussians for smoothing (i.e. scaling) and gaussian smoothed images

        % Create the levels
        imG = cell(levels+3,1);
        for i = 1:levels+3
            if cascade == 1                
                imG{i} = conv2(GP{i},GP{i},im2,'same');
                size(im2)
                size(imG{i})
            else
                imG{i} = conv2(GP{i},GP{i},im,'same');
            end
        end
        
        % Difference of gaussians
        if cascade==1
            imDoG = zeros(size(im2,1),size(im2,2),levels+2);
        else
            imDoG = zeros(size(im,1),size(im,2),levels+2);
        end
        
        for i = 1:levels+2
            imDoG(:,:,i) = imG{i+1} - imG{i};
        end

        % Check nearby extrema in subsequent layers
        imExtrema = imregionalmax(imDoG);
        imExtrema = imExtrema(:,:,2:end-1);
        
        % Eliminate responses on the edge
        imExtrema(1,:,:) = 0;imExtrema(end,:,:) = 0;
        imExtrema(:,1,:) = 0;imExtrema(:,end,:) = 0;
        imDoG = imDoG(:,:,2:end-1);
    
        % Put local maxima in vector with corresponding sigma and test for
        % Flatness enhance location and eliminate edge responses
        for i = 1:levels
            % Current sigma and octave scale
            if cascade==1
                scale = 2.0^(cascade-1.0)/2.0;
            else
                scale = 2.0^(cascade-1.0);
            end    
           
            sigmaC = scale*sigmaP*(k^(i-1));
            [row,col] = find(imExtrema(:,:,i)==1);
 
            % Test flatness
            flat = abs(diag(imDoG(row,col,i))) < tf;
            row = row(flat==0); col = col(flat==0);
            % Update location
        
            % Eliminate low edge responses by thresholding
            edge = zeros(length(row),1);
            for ind = 1:length(row)
                x = col(ind);
                y = row(ind);
                patch = imDoG(y-1:y+1,x-1:x+1,i);
                if checkForEdge(patch,10)
                    edge(ind) = 1;
                end
            end
            row = row(edge==0); col = col(edge==0);
            % Add new feature points
            loc = [loc; round(scale*col),round(scale*row),...
                    repmat(sigmaC,length(row),1)];
        end
    
        % Next Octave is subsampling the image
        im = imresize(im,0.5);
    end
end
