% Finds matching SIFT descriptors at Harris corner points in two images.
% inputs:
%		im1 - first image to match
%		im2 - second image to match
%		tf_reject - matching reject threshold -- can be 0.8
%       tf_harris - harris corner detector threshold -- can be 0.001
% outputs:
%       matches - 2d array of all matched feature points
%		match1 - the coordinates of the matches in image 1
%		match2 - the coordinates of the matches in image 2 matched to the ones in image 1
%       coord1 - the coordinates of te feature points in image 1

function [matches, match1, match2, coord1] = findMatches(im1, im2, tf_dog_flatness, tf_reject, tf_harris)
    im1 = single(rgb2gray(im1));
    im2 = single(rgb2gray(im2));
    
    loc1                  = DoG(im1, tf_dog_flatness);
%     imshow(im1); hold on;
%     scatter(loc1(:, 1), loc1(:, 2), loc1(:, 3) * 4, [1, 1, 0]);
    [r1, c1, sigma1]      = harrisImpl(im1, loc1, tf_harris);
    orient1               = zeros(size(sigma1));
    [coord1, descriptor1] = sift(im1, 'frames', [c1'; r1'; sigma1'; orient1']);
    
    loc2                  = DoG(im2, tf_dog_flatness);
    [r2, c2, sigma2]      = harrisImpl(im2, loc2, tf_harris);
    orient2               = zeros(size(sigma2));
    [coord2, descriptor2] = sift(im2, 'frames', [c2'; r2'; sigma2'; orient2']);

    % Create two arrays containing the points location in both images
    matches = [];
    match1 = [];
    match2 = [];
    descriptor1 = double(descriptor1);
    descriptor2 = double(descriptor2);
    % Loop over the descriptors of the first image
    for index1 = 1:size(descriptor1, 2)
        bestmatch      = [0 0];
        bestDist       = Inf;
        secondBestDist = Inf;

        % Loop over the descriptors of the second image
        for index2 = 1:size(descriptor2, 2)
            desc1 = double(descriptor1(:, index1));
            desc2 = double(descriptor2(:, index2));

            % Normalize the descriptors to unit L2 norm:
            desc1 = desc1 / max(desc1);
            desc2 = desc2 / max(desc2);

            % Compute the Euclidian distance of desc1 and desc2
            dist = sqrt(sum((desc1 - desc2).^2));

            % tf_harrishold the distances
            if secondBestDist > dist
                if bestDist > dist
                    secondBestDist = bestDist;
                    bestDist       = dist;
                    bestmatch      = [index1 index2];
                else % if not smaller than both best and second best dist
                    secondBestDist = dist;
                end
            end
        end

        % Reject matches where the distance ratio is greater than 0.8
        if (bestDist / secondBestDist) < tf_reject
            matches = [matches, [bestmatch(1); bestmatch(2)]];
            pts1 = coord1(:,bestmatch(1));
            pts2 = coord2(:,bestmatch(2));
            match1 = [match1, pts1];
            match2 = [match2, pts2];
        end
%         figure; imshow([im1, im2], []);
%         hold on;
%         scatter(coord1(1,:), coord1(2,:), coord1(3,:), [1,1,0]);
%         scatter(size(im1,2)+coord2(1,:), coord2(2,:), coord2(3,:), [1,1,0]);
%         drawnow;
%         line([match1(1,:); size(im1,2)+match2(1,:)],[match1(2,:); match2(2,:)]);
    end
end
