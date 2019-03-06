function [A, b] = matrixAb(match1, match2)
% matches in n,x,y format
%   Needs vectorization

A = zeros(2*size(match1, 2), 6);
b = zeros(2*size(match1, 2), 1);

for i = 1:length(b)/2
    p = [match1(1, i), match1(2, i), 0, 0, 1, 0; ...
        0, 0, match1(1, i), match1(2, i), 0, 1];
    A(2*i-1:2*i, :) = p;
    b(2*i-1:2*i) = [match2(1, i), match2(2, i)];
end

end

