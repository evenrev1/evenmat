function [X,Y] = halo(x,y,dx,dy)
% HALO	Convex hull with some space around (2D)
% 
% [x,y] = halo(x,y,dx,dy)
% 
% x,y	= input array of 2D coordinates
% dx	= a) space in x-direction in same units as x, or 
%         b) if no dy input, fraction determining spacing in both
%            directions.   
% dy	= space in y-direction in same units as y.
% 
% If no dx or dy is input, spacing around the cluster of positions is
% determined as fraction of the range of data in each dimension, either
% given as dx input alone or as the default of 0.1 (10%) when nothing is
% given.
%
% In contrast to CONVHULL, HALO gives positions, not indices to the
% input data. 
%
% See also CONVHULL

% Last updated: Wed Apr 19 00:22:24 2023 by jan.even.oeie.nilsen@hi.no

% Check input:
error(nargchk(2,4,nargin));

% Defaults:
if nargin<4 | isempty(dy),	
  if isscalar(y), dy=.1; else, dy=range(y)*.1; end
end
if nargin==3 & ~isempty(dx),
  if isscalar(y), dy=.1; else, dy=range(y)*dx; end
  if isscalar(x), dx=.1; else, dx=range(x)*dx; end	
elseif nargin<3 | isempty(dx),	
  if isscalar(x), dx=.1; else, dx=range(x)*.1; end	
end

% Build a larger dataset by simply duplicating and shifting in four
% directions:
X(:,:,1)=x;    Y(:,:,1)=y+dy; 
X(:,:,2)=x+dx; Y(:,:,2)=y; 
X(:,:,3)=x;    Y(:,:,3)=y-dy; 
X(:,:,4)=x-dx; Y(:,:,4)=y; 

j=convhull([X(:),Y(:)]);

X=squeeze(X(j));
Y=squeeze(Y(j));

