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
    numer = zeros(1,length(match1));
    for i = 1:length(numer)
        numer(i) = match2(:,i)' * F * match1(:,i);
    end
    a = (F * match1).^2;
    b = (F' * match1).^2;
    denom = a(1,:) + a(2,:) + b(1,:) + b(2,:);
    sd    = numer./denom;

    % Return inliers for which sd is smaller than threshold
    inliers = find(sd<threshold);

end
