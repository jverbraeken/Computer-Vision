function [matches] = findMatches(d1, d2)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    % Converting to grayscale and single for using vl
    
    %im1 = single(rgb2gray(im1));
    %im2 = single(rgb2gray(im2));
   
    
    matches = [];
    threshold = 100;
    
    % Loop over the descriptors of the first image
    for index1 = 1:size(d1, 2)

        bestDist = Inf;
        secondBestDist = Inf;
        bestmatch = [0; 0];
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
                        bestmatch = [index1; index2];
                    else % if not smaller than both best and ... second best dist
                        secondBestDist = dist;
                    end
                end
            end
        end
        
        % Keep the best match and draw
        if (bestDist / secondBestDist) < 0.8
            matches = [matches bestmatch];
            %c = [c1(bestmatch(1)), size(im1, 2) + c2(bestmatch(2))];
            %r = [r1(bestmatch(1)) r2(bestmatch(2))];
            %line(c, r, 'Color', 'green')
             % You can use the 'line' function in matlab to ... draw the matches
        end
    end
    
    %viscircles([c(1), r(1)], s1(bestmatch(1)));
    %viscircles([c(2), r(2)], s2(bestmatch(2)));
    
    

end

