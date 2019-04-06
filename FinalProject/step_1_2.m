function [C, matches] = step_1_2(step1, choice_step1, dir_generated, dir_features, n, images)
    switch choice_step1
        case step1.haraff_hesaff
            cache_matches_haraff_hesaff = strcat(dir_generated, 'matches_haraff_hesaff.mat');
            cache_C_haraff_hesaff = strcat(dir_generated, 'C_haraff_hesaff.mat');
            if exist(cache_matches_haraff_hesaff) && exist(cache_C_haraff_hesaff)
                load(cache_matches_haraff_hesaff);
                load(cache_C_haraff_hesaff);
            else
                % 2nd step also included: Apply normalized 8-point RANSAC algorithm to find best matches
                [C, ~, matches] = ransac_match(dir_features);
                save(cache_matches_haraff_hesaff, 'matches');
                save(cache_C_haraff_hesaff, 'C');
            end

        case step1.library
            cache_matches_library = strcat(dir_generated, 'matches_library.mat');
            cache_C_library = strcat(dir_generated, 'C_library.mat');
            if exist(cache_matches_library) && exist(cache_C_library)
                load(cache_matches_library);
                load(cache_C_library);
            else
                for i = 1:n
                    fprintf("Iteration %d of %d\n", i, n);
                    next = mod(i, n) + 1;
                    [feature_coordinates_1, feature_descriptors_1] = sift(single(rgb2gray(images(:, :, :, i))));
                    [feature_coordinates_2, feature_descriptors_2] = sift(single(rgb2gray(images(:, :, :, next))));
                    matches_ = vl_ubcmatch(feature_descriptors_1, feature_descriptors_2);
                    match_coordinates_1 = feature_coordinates_1(:,matches_(1,:));
                    match_coordinates_2 = feature_coordinates_2(:,matches_(2,:));

                    % 2nd step: Apply normalized 8-point RANSAC algorithm to find best matches
                    % disp("2nd step: Apply normalized 8-point RANSAC algorithm to find best matches");
                    [~, inliers] = estimateFundamentalMatrix(match_coordinates_1(1:2, :), match_coordinates_2(1:2, :));
                    matches{i} = matches_(:,inliers);
                    C{i} = feature_coordinates_1(1:2, :);
                end
                save(cache_matches_library, 'matches');
                save(cache_C_library, 'C');
            end

        case step1.own
            cache_matches_own = strcat(dir_generated, 'matches_own.mat');
            cache_C_own = strcat(dir_generated, 'C_own.mat');
            if exist(cache_matches_own) && exist(cache_C_own)
                load(cache_matches_own);
                load(cache_C_own);
            else
                for i = 1:n
                    fprintf("Iteration %d of %d\n", i, n);
                    next = mod(i, n) + 1;
                    dog_flatness_thres = 0.01;
                    dist_thres = 0.8;
                    edge_thres = 0.1;  % Maybe 0.001
                    [matches_, match_coordinates_1, match_coordinates_2, feature_coordinates_1] = findMatches(images(:, :, :, i), images(:, :, :, next), dog_flatness_thres, dist_thres, edge_thres);

                    % 2nd step: Apply normalized 8-point RANSAC algorithm to find best matches
                    % disp("2nd step: Apply normalized 8-point RANSAC algorithm to find best matches");
                    [~, inliers] = estimateFundamentalMatrix(match_coordinates_1(1:2, :), match_coordinates_2(1:2, :));
                    matches{i} = matches_(:,inliers);
                    C{i} = feature_coordinates_1(1:2, :);
                end
                save(cache_matches_own, 'matches');
                save(cache_C_own, 'C');
            end
    end
end
