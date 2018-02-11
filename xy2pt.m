function [X,Y]=xy2pt(x,y,inv,h);
% XY2PT		Transform coordinates in data units to points 
%
% [X,Y] = xy2pt(x,y,inv,h);
%
% x,y	= Vectors/arrays of data coordinates in reference axes
% inv	= Any non-empty input gives the inverse transformation (from
%         points to data units of reference axes) 
% h	= Handle to reference axis (default = current axes)
%
% X,Y	= Vectors/arrays of coordinates in points relative to axis origo
%
% The transformation is based on the position and data ranges of the
% reference axis. The point-coordinates are relative to axis origo.  Now
% angles and relative distances of graphics can be calculated.  The results
% can then be transformated back into the original coordinates by inverse
% XY2PT.  The need for this function comes from the lack of position
% information other than in data units, on plotted objects.
%
% PROBLEMS: Does not work on nonlinear axes
%
% See also AXIS XLIM YLIM

error(nargchk(2,4,nargin));
if nargin<4|isempty(h),	  h=gca;		end

uni=get(h,'units');			% get units

set(h,'units','points'); get(h,'position');
dx=ans(3);		dy=ans(4);		% axis ranges in points

xr=get(h,'xlim');	yr=get(h,'ylim');
Dx=xr(2)-xr(1);		Dy=yr(2)-yr(1);		% axis ranges in data units

if nargin<3|isempty(inv)
  X=(x-xr(1))/Dx*dx;	Y=(y-yr(1))/Dy*dy;	% transformation
else
  X=x*Dx/dx+xr(1);	Y=y*Dy/dy+yr(1);	% inverse
end

set(h,'units',uni);			% reset units 