% Final Project

%% 1st step: Read the images and resize

I = imageParser('model_castle', 'JPG');
I = imresize(I, 0.5);

%% 2nd step: Find correspondences between consecutive matching

ind = randi(size(I, 4), 1, 1);
dist_thres = 0.8;
edge_thres = 0.1;
mode = 'own';
if (ind == size(I, 4))
    [match1, match2] = findMatches(I(:,:, ind), I(:,:,1), dist_thres, edge_thres, mode);
else
    [match1, match2] = findMatches(I(:,:,ind), I(:,:,ind+1), dist_thres, edge_thres, mode);
end

%%