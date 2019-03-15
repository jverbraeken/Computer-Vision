% Function [Xout, T] = normalize( X )
% Normalize all the points in each image
% Input
%     -X: a matriX with 2D inhomogeneous X in each column.
% Output: 
%     -Xout: a matriX with (2+1)D homogeneous X in each column;
%     -matrix T: normalization matrix

function [Xout, T] = normalize( X )

    % Compute Xmean: normalize all X in each image to have 0-mean
    Xmean =  ...

    % Compute d: scale all X so that the average distance to the mean is sqrt(2).
    % Check the lab file for details.
    d = ...

    % Compose matrix T
    T = ...

    % Compute Xout using X^ = TX with one extra dimension (We are using homogenous coordinates)
    Xout = T * [X; ones(1,size(X,2))];

end
