function [X,Y]=rel(x,y);
% REL		Transform into normalized coordinates
%
% [X,Y] = rel(x,y);
%
% x,y	= vectors/arrays of coordinates in current axes
%
% X,Y	= vectors/arrays of coordinates in normalised axes (0-1) 

% Normalised coordinates 
xr=get(gca,'xlim');	yr=get(gca,'ylim'); 
dx=xr(2)-xr(1);		dy=yr(2)-yr(1);

X=(x-xr(1))/dx;		Y=(y-yr(1))/dy;