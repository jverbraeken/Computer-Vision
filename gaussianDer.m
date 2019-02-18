function Gd = gaussianDer(G, sigma)
    med = round(length(G)/2);
    
    y = 1:length(G);
    x = abs(med - y);
    Gd = -x.*G / (sigma^2);
end