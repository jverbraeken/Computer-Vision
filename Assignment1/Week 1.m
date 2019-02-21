function G = gaussian(sigma)
    result = zeros(3*sigma, 1);
    for i = 1:3*sigma
        result(i) = exp((-i^2)/(2 * sigma^2)) / (sigma * sqrt(2 * pi));
    end
end