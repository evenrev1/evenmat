function wmo = findwmo(lon,lat)
% FINDWMO	Gives the WMO square numbers of positions.
% 
% wmo = findwmo(lon,lat)
% 
% Returns NaNs for NaN positions. 
% 
% http://wiki.gis.com/wiki/index.php/World_Meteorological_Organization_squares
%
% See also WMOSQUARE CREATE_WMO_BOXES

error(nargchk(2,2,nargin));
size(lon);
if ans~=size(lat), error('Input is not of equal size!'); end

% Init empty matrix for the wmo numbers:
wmo=nans(ans);	

% Correct and check positions:
lon>180;lon(ans)=lon(ans)-360;
lon<-180;lon(ans)=lon(ans)+360;
if any(lon<-180) | any(180<lon) | any(lat<-90) | any(90<lat)
  error('Non-existent position entered!');
end
% Put positions on the 'far edges' inside range:
lon(lon==180)=179; lat(lat==90)=89; 
lon(lon==-180)=-179; lat(lat==-90)=-89; 

% Assign first digit in the wmo number according to quadrant:
wmo(lon>=0 & lat>=0) = 1000;  % 1=NE
wmo(lon>=0 & lat< 0) = 3000;  % 3=SE
wmo(lon< 0 & lat< 0) = 5000;  % 5=SW 
wmo(lon< 0 & lat>=0) = 7000;  % 7=NW
% Assign second digit according to latitude:
fix(lat/10); wmo=wmo+abs(ans)*100;
% Assign two last digits according to longitude:
fix(lon/10); wmo=wmo+abs(ans);
