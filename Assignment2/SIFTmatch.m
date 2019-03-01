function [] = SIFTmatch(im1, im2, tf)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    % Converting to grayscale and single for using vl
    
    im1 = single(rgb2gray(im1));
    im2 = single(rgb2gray(im2));
    
    % Find features and make descriptor of image 1 2
    loc1 = DoG(im1, tf);
    [r1,c1,s1] = harris(im1, loc1);
    [f1,d1] = vl_sift(single(im1));

    % Find features and make descriptor of image 1
    loc2 = DoG(im2, tf);
    [r2,c2,s2] = harris(im2, loc2);
    [f2,d2] = vl_sift(single(im2));

    % Loop over the descriptors of the first image
    for index1 = 1:size(d1, 2)

        bestDist = Inf;
        secondBestDist = Inf;
        bestmatch = [0 0];

        % Loop over the descriptors of the second image
        for index2 = 1:size(d2, 2)
            desc1 = d1(:,index1);
            desc2 = d2(:,index2);

            % Compute the Euclidian distance of desc1 and desc2 21
            dist = abs(desc1 - desc2);
            % Threshold the distances
            if dist < threshold
                if secondBestDist > dist
                    if bestDist > dist
                        secondBestDist = bestDist;
                        bestDist = dist;
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

end

