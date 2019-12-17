% WMO_SQUARE_DEMO	Just a script to demonstrate how WMO-squares
% are defined. With a simple graphics showing it.
% 
% See also FINDWMO WMOSQUARE

[lon,lat]=meshgrid(-180:10:170,-90:10:80);
[M,N]=size(lon);
wmo=nans(M,N);

% https://en.wikipedia.org/wiki/World_Meteorological_Organization_squares
wmo(lon>=0&lat>=0)=1000;  % 1=NE
wmo(lon>=0&lat<0)=3000;  % 3=SE
wmo(lon<0&lat<0)=5000;  % 5=SW 
wmo(lon<0&lat>=0)=7000;  % 7=NW
% The second digit (x0xx through x8xx) indicates the number of tens of
% degrees latitude (north in global quadrants 1 and 7, south in global
% quadrants 3 and 5) of the 'minimum' square boundary (nearest to the
% Equator), i.e. a cell extending between 10°N and 20°N (or 10°S and
% 20°S) has this digit = 1.
floor(lat/10); ans(ans<0)=ans(ans<0)+1; wmo=wmo+abs(ans)*100;
% The third and fourth digits (xx00 through xx17) similarly indicate the
% number of tens of degrees of longitude of the 'minimum' square
% boundary, nearest to the Prime Meridian.
floor(lon/10); ans(ans<0)=ans(ans<0)+1; wmo=wmo+abs(ans);

epcolor(lon+5,lat+5,wmo);
tallibing(lon+5,lat+5,wmo,[],'k');
