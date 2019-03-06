% Final Project

%% 1st step: Read the images and resize

I = imageParser('model_castle', 'JPG');
I = imresize(I, 0.1);

%% 2nd step: Find correspondences between consecutive matching

ind = randi(size(I, 4), 1, 1);
tf = 0.01;
thres = 0.1;
if (ind == size(I, 4))
    matches = SIFTmatch(single(rgb2gray(I(:,:,:,ind))), single(rgb2gray(I(:,:,:,0))), tf, thres);
else
    matches = SIFTmatch(single(rgb2gray(I(:,:,:,ind))), single(rgb2gray(I(:,:,:,ind+1))), tf, thres);
end

