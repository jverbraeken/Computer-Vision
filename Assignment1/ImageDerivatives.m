%% Exercise 5.4

function F = ImageDerivatives(img, sigma, type)

    G = gaussian(sigma);
    med = round(length(G)/2);
    y = 1:length(G);
    x = y - med;
    switch type
        case {'x', 'y', 'xy', 'yx'}
            Gd = gaussianDer(G, sigma);
        case {'xx', 'yy'}
            Gd = G .* ((-sigma^2 + x.^2)/sigma^4);
    end
       
    switch type
        case 'x'
            F = conv2(img, Gd, 'same');
        case 'y'
            F = conv2(img, Gd', 'same');
        case {'xy', 'yx'}
            F = conv2(Gd, Gd, img, 'same');
        case 'xx'
            F = conv2(img, Gd, 'same');
        case 'yy'
            F = conv2(img, Gd', 'same');
        otherwise
            F = conv2(img, G, 'same');
    end
    
    %imshow(F, []);
    
end
