function [lon,lat,sic] = esic(plon,plat,day,rlat,mfac);
% ESIC	Sea ice concentration from NOAA's griddap server.
% Gives sea ice concentration from gridded dataset around a specified
% location or in specified region for a specific specified day.
%
% [lon,lat,sic] = esic(plon,plat,day,rlat,mfac)
% 
% plon,plat = Scalar positon of the point of interest, or 2 element
%	      row vectors defining ranges for the region of interest. 
% day	    = the day of interest in Matlab serial days. Can be
%	      anytime during the day, but only one day
%	      (default = now).
% rlat      = radius of region to inquire in degrees latitude 
%	      (default = 4). Obsolete when plon and plat are ranges.
% mfac	    = scaling factor for the size of the markers on map,
%	      facilitating adjustments fo different size maps
%	      (default = 2e3).
%
% lon,lat   = Vectors with the positions of the found gridcells in
%	      the inquired region.
% sic       = Vector with the corresponding sea ice concentrations as 
%	      fractions.
%
% If no output is requested, an m_map representation or addition to an
% existing m_map of the grid points and their concentration is
% made. The plotted points will be tagged 'esic_points' and the
% legend axes objects are tagged 'esic_legend_object', in case you
% want to remove them.
% 
% Data is read on demand from https://polarwatch.noaa.gov/erddap/griddap/.
%
% Last updated: Sun Sep 17 20:50:01 2023 by jan.even.oeie.nilsen@hi.no
% 
% See also M_SCATTER SCATTER WEBREAD
 

error(nargchk(0,5,nargin));
if nargin<5 | isempty(mfac),	mfac=2e3;	end
if nargin<4 | isempty(rlat),	rlat=4;		end
if nargin<3 | isempty(day),	day=floor(now);	end
if nargin<2 | isempty(plat) | isempty(plon), plat=[];plon=[];	end

% Define region:
if (isempty(plon) | isempty(plat)) & ~isempty(get(0,'children'))
  a=get(gca);
  if contains(a.Tag,'m_grid')
    ma=m_proj('get'); 
    region=[ma.longs ma.lats];
  else
    error('Current axis must be an m_map for no plon/plat input!');
  end
elseif size(plon)==[1 2] & size(plat)==[1 2]
  region=[plon plat]; 
  rlat=diff(plat)/2;
elseif size(plon)==[1 1] & size(plat)==[1 1] & size(rlat)==[1 1]
  region=[plon+[-1 1]*rlat/cosd(plat),plat+[-1 1]*rlat];
else
  error('Input plon, plat or rlat has the wrong size!')
end

% Check date and select data product:
date=datestr(floor(day),29);
if datenum(date)>now-2
  date=datestr(now-2,29)
  file='nsidcG10016v2nh1day';
elseif datenum(date)>=datenum('01-Jan-2021')
  file='nsidcG10016v2nh1day';
elseif datenum(date)>=datenum('01-Jan-1978')
  file='nsidcG02202v4nh1day'
else 
  error('Date out of range!');
end

% Read lon/lat grid:
if logical(1)
  dx=int2str(1); dy=int2str(1);
  %weboptions=setfield(weboptions,'Timeout',20); 
  sig=webread(['https://polarwatch.noaa.gov/erddap/griddap/',...
	      'nsidcCDRice_nh_grid.json?',...
	      'longitude%5B(5837500.0):',dx,':(-5337500.0)%5D%5B(-3837500.0):',dx,':(3737500.0)%5D,',...
	      'latitude%5B(5837500.0):',dy,':(-5337500.0)%5D%5B(-3837500.0):',dy,':(3737500.0)%5D']);%,weboptions);
end
lon=sig.table.rows(:,3);
lat=sig.table.rows(:,4);

% Read SIC for that day:
si=webread(['https://polarwatch.noaa.gov/erddap/griddap/',...
	    file,'.json?cdr_seaice_conc',...
	    '%5B(',date,'):1:(',date,')',...
	    '%5D%5B(5837500.0):',dx,':(-5337500.0)',...
	    '%5D%5B(-3837500.0):',dy,':(3737500.0)%5D']);%,weboptions);
  
% Define area, find gridcells inside, and get SIC there:
[LON,LAT] = erect(region,'t');
I=find(inpolygon(lon,lat,LON,LAT));
sic=nans(size(lon));
for i=1:length(I)
  si.table.rows{I(i)}{4};
  if ~isempty(ans) & ans>0.2, sic(I(i))=ans; end
end

% Limit to the found gridcells:
lon=lon(I); lat=lat(I); sic=sic(I);

% Make a plot if no output is requested:
if nargout==0
  sic(sic>1)=0; % Remove too high values
  %sic(sic>0)=1; % Test of marker size
  a=get(gca);
  if ~contains(a.Tag,'m_grid')
    clf;
    m_proj('albers','long',mima(lon),'lat',mima(lat)); 
    m_coast('color','k')
    m_grid;
  end
  hold on
  ma=m_proj('get'); 
  rlat=diff(ma.lats)/2;
  hic=m_scatter(lon,lat,(sic+1e-6)*str2num(dx)*mfac/(rlat),[0 0 1]); set(hic,'marker','.');
  set(hic,'Tag','esic_points');
  % Legend objects in same axes: 
  x=repmat(max(xlim),1,3);
  y=max(ylim)-diff(ylim)*[0 0.05 0.1];
  sl=([1 .5 .1]+1e-6)*str2num(dx)*mfac/rlat;
  hl=scatter(x,y,sl,[0 0 1]);
  ht=text(x,y,[' 100% SIC';'  50% SIC';'  10% SIC']);
  set(hl,'marker','.');
  set([hl;ht],'Tag','esic_legend_object');
  hold off
  % % Separate axes for legend:
  % lax=axes('position',[0 0 .2 .1]);
  % set(lax,'units','points');
  % get(lax,'position');set(lax,'position',[ans(1:2)+10 70 30]);
  % x=[0 0 0]; y=[.8 .5 .2]; 
  % sl=([1 .5 .1]+1e-6)*str2num(dx)*mfac/rlat;
  % hl=scatter(x,y,sl,[0 0 1]);
  % ht=text(x,y,[' 100% SIC';'  50% SIC';'  10% SIC']);
  % set(lax,'xlim',[0 1],'ylim',[0 1]);
  % set(hl,'marker','.');
  % set(lax,'Tag','esic_legend');
  % set(lax,'visible','off');
end


% https://polarwatch.noaa.gov/erddap/griddap/noaacwAMSR2gw1IceConcDailyNP06.json?IceConc%5B(2023-09-13T12:29:53Z):1:(2023-09-13T12:29:53Z)%5D%5B(0.0):1:(0.0)%5D%5B(8829468.75):1:(-8829468.75)%5D%5B(-8829468.75):1:(8829468.75)%5D
