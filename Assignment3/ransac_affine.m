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
    miniterations = 3;

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
        [A, b] = matrixAb(match1(:, perm), match2(:, perm));

        % (3) Fit model h over the matches
        h = pinv(A) * b;
        [Atot, ~] = matrixAb(match1, match2);
        b_prime = Atot * h;  

        %{
        % (4) Transform all points from image1 to their counterpart in image2. Plot these correspondences.
        %match in c,r format, match1transformed in x,y format -> got to
        %change thats
        figure; imshow([im1 im2], []); hold on;
        match1transformed = reshape(A * h, 2, 3);
        x = [match1(1,perm); match1transformed(1,:) + size(im1,2)];
        y = [match1(2,perm); match1transformed(2,:)];
        
        % the line function doesn't work properly vectorized -> need for
        % loop
        line(x(:) , y(:), 'Color', 'green');
        title('Image 1 and 2 with the original points and their transformed counterparts in image 2');
        %}
        
        % (5) Determine inliers using the threshold and save the best model
        % inliers based on all the points? Do we need to recompute A based
        % on all points?
        %inliers = find(sqrt((match1transformed(1,:) - match2(2, perm)).^2 + ...
         %   (match1transformed(2,:) - match2(1, perm)).^2) < threshold);
        inliers = find(sqrt((b_prime(1:2:end) - match2(1, :)').^2 + ...
            (b_prime(2:2:end) - match2(2, :)').^2) < threshold);
        

        % (6) Save the best model and redefine the stopping iterations
        if (length(inliers) > bestinliers)
            bestinliers = inliers;
            best_h = h;
            iterations = round(log10(0.001) / log(1 - (length(bestinliers)/length(match1))^ P));
        end    

        i = i+1;
    end
end
