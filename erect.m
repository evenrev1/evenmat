function [x,y]=erect(lim,options)
% ERECT         vector-rectangle-description 
% makes two vectors describing the edges of a rectangle from four point
% corner/limits-coordinates. 
%
% [x,y]=erect(lim,options)
%
% lim     = [xmin xmax ymin ymax] four point vector describing limits of
%           rectangle.
% [x,y]   = two 5 point long vectors decribing the edges of rectangle all
%           the way around.
% options = characters for options:
%     't' = 'tight' fills in points between the corners in case the
%           rectangle is to be projected.

error(nargchk(1,2,nargin));
if lim(1) > lim(2) | lim(3) > lim(4)
  error('Limits vector must be of the form [xmin xmax ymin ymax]!')
end
if nargin < 2 | isempty(options)
  options='';
end

if findstr(options,'t')   % fill in with 100 points between corners
  hor=lim(1):(lim(2)-lim(1))/100:lim(2);
  ver=lim(3):(lim(4)-lim(3))/100:lim(4);
  x=[hor lim(2).*ones(1,length(ver)) fliplr(hor) lim(1).*ones(1,length(ver))];
  y=[lim(3).*ones(1,length(hor)) ver lim(4).*ones(1,length(hor)) fliplr(ver)];
else                      % jump from corner to corner
  x=lim([1 2 2 1 1]);
  y=lim([3 3 4 4 3]);
end
