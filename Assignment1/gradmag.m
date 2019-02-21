function [magnitude, orientation] = gradmag(img, sigma)
    h = gaussianDer(gaussian(sigma), sigma);
    img_x = imfilter(double(img), h);
    img_y = imfilter(double(img), h');
    
    
    magnitude = sqrt(img_x.^2 + img_y.^2);
    orientation = atan(img_y./img_x);
    
    figure
    subplot(2,1,1); imshow(magnitude, [])
    colormap(gray);
    
    
    subplot(2,1,2);
    imshow(orientation, [-pi, pi]);
    colormap(hsv);
    colorbar;
end