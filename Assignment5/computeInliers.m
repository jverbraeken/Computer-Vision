% function inliers = computeInliers(F,match1,match2,threshold)
% Find inliers by computing perpendicular errors between the points and the epipolar lines in each image
% To be brief, we compute the Sampson distance mentioned in the lab file.
% Input: 
%   -matrix F, matched points from image1 and image 2, and a threshold (e.g. threshold=50)
% Output: 
%   -inliers: indices of inliers
function inliers = computeInliers(F, match1, match2, threshold)

    % Calculate Sampson distance for each point
    % Compute numerator and denominator at first
    inliers = [];
    for i=1:size(match1, 2)
        numer = (match2(:, i)' * F * match1(:, i))^2;
        b = F * match1(:, i);
        c = F' * match2(:, i);
        denom = b(1)^2+b(2)^2+c(1)^2+c(2)^2;
        sd    = numer/denom;
        if sd < threshold
            inliers = [inliers, i];
        end
    end
    
    
    
    
    
    
    %numer = (match2' * F * match1).^2;
    %b = F * match1;
    %c = F' * match2;
    %denom = b(1)^2+b(2)^2+c(1)^2+c(2)^2;
    %sd    = numer/denom;

    % Return inliers for which sd is smaller than threshold
    %inliers = find(sd<threshold);

end
