function [siz,x,y]=egrid(x,y)
% EGRID         simple gridding of vector positions
% by finding the size of the field-matrix described by two
% position-vectors. The two vectors must describe an already gridded
% distribution of points, and the sequence must be ordered (taken rowwise or
% columnwise from position matrices). Using EGRID is then far more effective
% than GRIDDATA, since no interpolation is needed. EGRID can also shape the
% vectors (back) into matrices describing the positions.
%
% [siz,x,y]=egrid(x,y)
%
% x    = vector of positions along the x-axis
% y    = vector of positions along the y-axis
%
% siz  = [M N], the size of the field-matrix
% x,y  = position-matrices, reshaped from input x and y
% 
% The basic idea is that the vectors described above is likely to be the
% result of reshaping position matrices into vectors. Then one of these will
% have sequences of equal numbers, corresponding to the run-through of the
% other ordinate. A simple MESHGRID will not do in this case, since the same
% range of ordinates are run through several times in these vectors. 
%
% See also GRIDDATA MESHGRID RESHAPE COLON

%Time-stamp:<Last updated on 06/09/14 at 11:31:22 by even@nersc.no>
%File:</home/even/matlab/evenmat/egrid.m>

if isvec(x) & isvec(y) & length(x)==length(y)
  dix=diff(x);diy=diff(y);
  if ~dix(1)          % first two values in x are equal
    find(dix~=0);     % find the last of these first equal values
    M=ans(1);         % number of equal values of x =
                      % the length of run-through of y (height of matrix)
    N=length(x)/M;
  elseif ~diy(1)
    find(diy~=0); N=ans(1); M=length(y)/N;
  else
    error('Vectors must describe an uniform distribution!')
  end 
  siz=[M N]; x=reshape(x,M,N); y=reshape(y,M,N);
elseif ismatrix(x) & ismatrix(y) & size(x)==size(y)
  siz=size(x); x=x(:); y=y(:);
else
  error('Input needs to be both vectors of equal length or both matrices of equal size!');
end

if nargout==2, siz=x; x=y; end


