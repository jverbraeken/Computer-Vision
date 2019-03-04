% Ransac implementation to find the affine transformation between two images.
% Input:
%       match1 - set of point from image 1
%       match2 - set of corresponding points from image 2
%       im1    - the first image
%       im2    - the second image
% Output:
%       best_h - the affine affine transformation matrix

function best_h = ransac_affine(match1, match2, im1, im2)
    % Iterations is automatically changed during runtime
    % based on inlier-count. Set min-iterations (e.g. 5 iterations) to circumvent corner-cases
    iterations = 100; 
    miniterations = 5;

    % Threshold: the 10 pixels radius
    threshold = 10;

    % The model needs at least ? point pairs (? equations) to form an affine transformation
    P = 3;

    % Start the RANSAC loop
    bestinliers = 0;
    best_h = zeros(6,1);

    i=1;
    while ((i<iterations) || (i<miniterations))
        % (1) Pick randomly P matches
        perm = randperm(length(match1), P);

        % (2) Construct matrices A, h, b 
        A = zeros(2*P, 6);
        b = zeros(2*P, 1);
        for j = 1:P
            p = [match1(2, perm(j)), match1(1, perm(j)), 0, 0, 1, 0; ...
                0, 0, match1(2, perm(j)), match1(1, perm(j)), 0, 1];
            A(2*j-1:2*j, :) = p;
            b(2*j-1:2*j) = [match2(2, perm(j)), match2(1, perm(j))];
        end


        % (3) Fit model h over the matches
        h = pinv(A) * b;


        % (4) Transform all points from image1 to their counterpart in image2. Plot these correspondences.
        %match in c,r format, match1transformed in x,y format -> got to
        %change that
        figure; imshow([im1 im2]); hold on;
        match1transformed = reshape(A * h, 2, 3);
        x = [match1(1,perm); match1transformed(2,:) + size(im1,2)];
        y = [match1(2,perm); match1transformed(1,:)];
        
        % the line function doesn't work properly vectorized -> need for
        % loop
        line(x(:) , y(:), 'Color', 'green');
        title('Image 1 and 2 with the original points and their transformed counterparts in image 2');
    
        % (5) Determine inliers using the threshold and save the best model
        % inliers based on all the points? Do we need to recompute A based
        % on all points?
        inliers = find(sqrt((match1transformed(1,:) - match2(2, perm)).^2 + ...
            (match1transformed(2,:) - match2(1, perm)).^2) < threshold);

        % (6) Save the best model and redefine the stopping iterations
        if (length(inliers) > bestinliers)
            bestinliers = perm(inliers);
            best_h = h;
        end    

        iterations = log10(0.001) / log(1 - (length(inliers)/length(match1))^ P);

        i = i+1;
    end
end
