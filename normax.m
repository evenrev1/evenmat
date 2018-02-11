function [X,Y]=normax(x,y,inv,h);
% NORMAX	Transform into normalized equal aspect coordinates
%
% [X,Y] = normax(x,y,inv,h);
%
% x,y	= Vectors/arrays of coordinates in reference axes
% inv	= Any input gives the inverse transformation (from normalized
%	  coordinates to coordinates in reference axes)
% h	= Handle to reference axis (default = current axes)
%
% X,Y	= Vectors/arrays of coordinates in normalized axes
%
% The normalization of NORMAX is based on the visual position and data
% ranges of the reference axis. Data is transformed into axes with 1/1
% aspect ratio and range 0 to 1 on longest looking axis. Thus visual
% distances and angles can be calculated correctly. The results can be
% transformated back into the original coordinates by inverse NORMAX.  The
% need for this function comes from the lack of position information other
% than in data units, on plotted objects.
%
% PROBLEMS: Does not work on nonlinear axes
%
% EXAMPLE:  figure; x=[50 80 60 70]; y=[1 4 9 15]; subplot 121; plot(x,y); 
%	    [X,Y]=normax(x,y); subplot 122; plot(X,Y); axis image;
%
% See also AXIS XLIM YLIM

error(nargchk(2,4,nargin));
if nargin<4|isempty(h),	  h=gca;		end

set(h,'units','points'); get(h,'position');
dx=ans(3);		dy=ans(4);
dm=max(dx,dy);

xr=get(h,'xlim');	yr=get(h,'ylim');
Dx=xr(2)-xr(1);		Dy=yr(2)-yr(1);

if nargin<3|isempty(inv)
  X=(x-xr(1))/Dx*(dx/dm);	Y=(y-yr(1))/Dy*(dy/dm);	% transformation
else
  X=x*Dx/(dx/dm)+xr(1);	Y=y*Dy/(dy/dm)+yr(1);		% inverse
end
