%% Assignment 1, Exercise 1

function G = gaussian(sigma)
    halfsize = ceil(3*sigma);
    
    x = -halfsize:halfsize;
    G = exp(-x.^2/(2*sigma^2)) * (1/(sqrt(sigma*2*pi)));
   
end
