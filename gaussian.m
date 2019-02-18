%% Assignment 1, Exercise 1

function G = gaussian(sigma)
    G  = zeros(3*sigma, 1);
    med = round(length(G)/2);
    
    y = 1:length(G);
    x = abs(med - y);
    G = exp(-x.^2/(2*sigma^2)) * (1/(sqrt(sigma*2*pi)));
   
end
