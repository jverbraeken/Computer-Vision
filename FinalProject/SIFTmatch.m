function [matches] = SIFTmatch(im1, im2, tf, thres)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    % Converting to grayscale and single for using vl
    
    %im1 = single(rgb2gray(im1));
    %im2 = single(rgb2gray(im2));
    
    matches = [];
    
    % Find features and make descriptor of image 1 2
    loc1 = DoG(im1, tf);
    [r1,c1,s1] = harris(im1, loc1, thres);
    fc1 = [c1'; r1'; s1'; zeros(1, size(r1, 1))];
    [d1, ~] = vl_sift(single(im1), 'frames', fc1);

    % Find features and make descriptor of image 1
    loc2 = DoG(im2, tf);
    [r2,c2,s2] = harris(im2, loc2, thres);
    fc2 = [c2'; r2'; s2'; zeros(1, size(r2, 1))];
    [d2, ~] = vl_sift(single(im2), 'frames', fc2);

    threshold = 10;
    figure(3)
    imshow([im1 im2], [])
    
    tt = [];
    % Loop over the descriptors of the first image
    for index1 = 1:size(d1, 2)

        bestDist = Inf;
        secondBestDist = Inf;
        bestmatch = [0 0];
        desc1 = d1(:,index1);
        
        % Loop over the descriptors of the second image
        for index2 = 1:size(d2, 2)
            desc2 = d2(:,index2);

            % Compute the Euclidian distance of desc1 and desc2 21
            dist = sqrt(sum((desc1 - desc2) .^ 2));
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
            matches = [matches; bestmatch];
            figure(3)
            c = [c1(bestmatch(1)), size(im1, 2) + c2(bestmatch(2))];
            r = [r1(bestmatch(1)) r2(bestmatch(2))];
            viscircles([c(1), r(1)], s1(bestmatch(1)));
            viscircles([c(2), r(2)], s2(bestmatch(2)));
            line(c, r, 'Color', 'green') % You can use the 'line' function in matlab to ... draw the matches
        end
    end

end

