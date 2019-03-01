function [r, c, sigmas] = harris2(im, loc)
    % inputs: 
    % im: double grayscale image
    % loc: list of interest points from the Laplacian approximation
    % outputs:
    % [r,c,sigmas]: The row and column of each point is returned in r and c
    %              and the sigmas 'scale' at which they were found
    
    % Calculate Gaussian Derivatives at derivative-scale. 
    % NOTE: The sigma is independent of the window size (which dependes on the Laplacian responses).
    % Hint: use your previously implemented function in assignment 1 
    im = rgb2gray(im);
    
    gamma = 0.7;
    
    G = gaussian(gamma);
    Gder = gaussianDer(G, gamma);
    Ix =  conv2(im, Gder, 'same');
    Iy =  conv2(im, Gder', 'same');

    % Allocate an 3-channel image to hold the 3 parameters for each pixel
    init_M = zeros(size(Ix,1), size(Ix,2), 3);

    % Calculate M for each pixel
    init_M(:,:,1) = Ix .^2;
    init_M(:,:,2) = Iy .^2;
    init_M(:,:,3) = Ix .* Iy;

    
    % Allocate R 
    R = zeros(size(im,1), size(im,2), 2); 
    
    
    % Smooth M with a gaussian at the integration scale sigma.
    % Keep only points from the list 'loc' that are corners. 
    for l = 1 : size(loc,1)
        sigma = loc(l,3); % The sigma at which we found this point	
        if ((l>1) && sigma~=loc(l-1,3)) || (l==1)
            M = imfilter(init_M, fspecial('gaussian', ceil(sigma*6+1), sigma), 'replicate', 'same');
        end
	
        % Compute the cornerness R at the current location
        k = 0.04;
        trace_l = M(:, :, 1) + M(:, :, 2);
        det_l = M(:, :, 1) .* M(:, :, 2) - M(:, :, 3) .^ 2;
        %R(loc(l,2), loc(l,1), 1) = det_l - k*trace_l^2;
        
	% Store current sigma as well
        %R(loc(l,2), loc(l,1), 2) = sigma;
        R(l,2) = sigma;

    end
    % Display corners
    figure
    hold on
    imshow(im, [])
    viscircles([loc(:,1), loc(:,2)], R(:,2))

   
    % Set the threshold 
    threshold = 0.01 * max(R(:,:,1), [], 'all');

    % Find local maxima
    % Dilation will alter every pixel except local maxima in a 3x3 square area.
    % Also checks if R is above threshold
 
    % Non max supression	
    R(:,:,1) = ((R(:,:,1)>threshold) & ((imdilate(R(:,:,1), strel('square', 3))==R(:,:,1)))) ; 
       
    % Return the coordinates and sigmas
    [r, c, sigmas] = find(R);
end
