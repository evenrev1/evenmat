function [rx,ry]=rotax(x,y,angle,origo)
% ROTAX         rotates axis system of the input coordinates
% and returns new set of coordinates related to the rotated axes. 
%
% [rx,ry]=rotax(x,y,angle,origo)
%
% x,y   = original coordinates (vector)
% angle = angle to rotate axes (counterclockwise) 
% origo = vector-coordinate [x0 y0] around which to rotate the axes 
% 
% rx,ry = the new coordinates
%
% See also CART2POL

%Time-stamp:<Last updated on 01/01/15 at 13:55:30 by even@gfi.uib.no>
%File:<d:/home/matlab/rotax.m>

error(nargchk(3,4,nargin));
if nargin<4 | isempty(origo)
  x0=0; y0=0;
else
  x0=origo(1); y0=origo(2);
end


rx=x-x0; ry=y-y0;               % insert origo
[ang,r] = cart2pol(rx,ry);      % convert to polar coord.
ang=ang-angle*pi/180;           % subtract the given angle
                                % (we're rotating the axes, not the data)
[rx,ry] = pol2cart(ang,r);      % reconvert to cartesian
rx=rx+x0; ry=ry+y0;             % remove origo

if nargout==0                   % figure if no outarg
  fig rotax 4;
  plot(x,y,'ko',rx,ry,'r^');
  legend('input points','rotated points',['angle = ',num2str(angle)],0); 
  grid on;
end

