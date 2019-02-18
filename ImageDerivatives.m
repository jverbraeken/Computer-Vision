%% Exercise 5.4

function F = ImageDerivatives(img, sigma, type)

    switch(type)
        case 'x'
            h = gaussianDer(gaussian(sigma), sigma);
            F = imfilter(img, h);
        case 'y'
            h = gaussianDer(gaussian(sigma), sigma)';
        case 'xx'
            G = gaussian(sigma);
            med = round(length(G)/2);
            y = 1:length(G);
            x = y - med;
            h = (-sigma^2 + x.^2) .* G / (sigma^4);
            F = imfilter(double(img), h);
            imshow(F, []);
        case 'yy'
            G = gaussian(sigma);
            med = round(length(G)/2);
            y = 1:length(G);
            x = y - med;
            h = ((-sigma^2 + x.^2).*G / (sigma^4))';
            F = imfilter(img, h);
            
             
            
end
