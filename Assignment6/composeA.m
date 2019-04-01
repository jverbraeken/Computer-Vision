% function A = composeA(x1, x2)
% Compose matrix A, given matched points (X1,X2) from two images
% Input: 
%   -normalized points: X1 and X2 
% Output: 
%   -matrix A
function A = composeA(x1, x2)
    A = [(x1(1, :) .* x2(1, :)); (x1(1, :) .* x2(2, :)); x1(1, :); (x1(2, :).* x2(1, :));...
        (x1(2, :) .* x2(2, :)); x1(2, :); x2(1 ,:); x2(2, :); ones(length(x1), 1)']';

end
