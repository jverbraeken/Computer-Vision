%function Edge = checkForEdge(patch, r)
%The function checks for an edge in a patch of the DoG function
%
%INPUT
%- patch: a 3x3 patch of the DoG image
%- r:     threshold for the ratio between principal curvatures (default 10)
%
%OUTPUT
%- true if it is an edge else false
function Edge = checkForEdge(patch,r)

if nargin < 2
    r = 10;
end

fd  = [-0.333,0,0.333;-0.333,0,0.333;-0.333,0,0.333];
fdd = [-0.1667,0.333,-0.1667;-0.1667,0.333,-0.1667;-0.1667,0.333,-0.1667];
Dxx = sum(sum(patch.*fdd));
Dyy = sum(sum(patch.*fdd'));
Dx  =  sum(sum(patch.*fd));
Dy  =  sum(sum(patch.*fd'));
Dxy = Dx*Dy;
Tr2 = (Dxx+Dyy)^2;
Det = Dxx*Dyy - Dxy^2;
Edge = Tr2/Det > (r+1)^2/r;

