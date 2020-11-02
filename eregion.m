function [lo,la,da] = eregion(lon,lat,data,region)
% EREGION	Adapt any geographical gridded data for plot of a sub-region.
% 
% [lo,la,da] = eregion(lon,lat,data,region)
% 
% lon,lat = The positions of the input gridded data.
% data    = The values of the input gridded data.
% region  = If an m_map has been initiated, this input is
%           obsolete. Otherwise a four-element frame of region of 
%           interest, [west_lon east_lon south_lat north_lat], can be
%           input here. 
% 
% lo,la   = The altered positions of the input gridded data.
% da      = The altered values of the input gridded data.
%
% If no output is requested simple plots will be shown. Try this
% first, to validate the method.
%
% % When using pcolor or m_pcolor to plot data from irregular grids in
% longitude, latitude cooredinates, two problems may occur: 1) If the
% longitude 'jump' (i.e., the 0°=360° or -180°=180°) is in the middle of
% your region, the graph may only show half your data; 2) If the grid is
% irregular enough it seems pcolor wraps some values around the globe
% resulting in NaN cells gaining values that should not be there.  This
% function solves these issues by moving the 'jump' away from your
% region by changing the longitudes, and then setting all values outside
% your region to NaN.
% 
% See also PCOLOR M_PCOLOR M_PROJ ERECT

error(nargchk(3,4,nargin));
[M,N]=size(data);
if nargin<4 | isempty(region)
  global MAP_PROJECTION MAP_VAR_LIST MAP_COORDS
  if ~isempty(MAP_VAR_LIST)
    region=[MAP_VAR_LIST.longs,MAP_VAR_LIST.lats];+[-2 2 -1 1];
  else
    error('Region input not given and m_map has not been initialised! (Use M_PROJ.)'); 
  end 
end
region(3)=max(region(3),-90); region(4)=min(region(4),90);

% Check the input positions:
if region(2)-region(1)<=0 | region(4)-region(3)<=0
  error('Region input must have increasing longitudes and increasing latitudes!');
end

lo=lon; 

% First force the input longitudes to comply to -180- to 180 numbering:
lo>180; if any(ans,'all'), lo(ans)=lo(ans)-360; end

% Find where the 'jump' is and move if necessary.
mid=(region(1)+region(2))/2; % The longitude farthest away from the region
mid+180<lo; if any(ans,'all'), lo(ans)=lo(ans)-360; end
mid-180>lo; if any(ans,'all'), lo(ans)=lo(ans)+360; end

la=lat; da=data;

% Now just NaN out everything outside region:
[plo,pla]=erect(region,'t');	% a tight dense polygon
IN = inpolygon(lo,la,plo,pla);  % positions inside
da(~IN)=NaN;			% not inside are set to NaN

% Three plots:
if nargout==0
  if isempty(findobj(0,'name','eregion'))
    scr=get(0,'screensize');
    figure; set(gcf,'name','eregion',...
		    'position',scr.*[1 1 1 .5]);
  end
  subplot 131; pcolor(lon,lat,data); xlabel lon; ylabel lat; title input
  subplot 132; pcolor(lo,la,da); xlabel lo; ylabel la; title output
  subplot 133; m_pcolor(lo,la,da); m_grid; m_coast; title output
end
