% Find features and make descriptor of image 1 2
[r1,c1,s1] = harris(im1);
[f1,d1] = sift(single(im1),r1,c1, s1);
% Find features and make descriptor of image 1
[r2,c2,s2] = harris(im2);
[f2,d2] = sift(single(im2),r2,c2, s2);
% Loop over the descriptors of the first image
for index1 = 1:size(d1, 2)
    bestDist = Inf;
    secondBestDist = Inf;
    bestmatch = [0 0];
    % Loop over the descriptors of the second image
    for inex2=1:size(d2, 2)
        desc1 = d1(:,index1);
        desc2 = d2(:,index2);
        % Compute the Euclidian distance of desc1 and desc2 21
        dist = ...
        % Threshold the ditances
        if dist < threshold
            if secondBestDist > dist
                if bestDist > dist
                    seccondBestDist = bestDist;
                    bestDis = dist;
                    bestmatch = [index1 index2];
                else % if not smaller than both best and ... second best dist
                    secondBestDist = dist;
                end
            end
        end
    end
    % Keep the best match and draw
    if (bestDist / secondBestDist) < 0.8
        ... % You can use the 'line' function in matlab to ... draw the matches
    end
end
% Return matches between the images
