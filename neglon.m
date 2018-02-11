function lon = neglon(lon)
% NEGLON	Change 0-360 deg to -180-180 deg
% 
% lon = neglon(lon)
% 
% lon =	Input of all positive longitudes (0-360) are converted
%       to have negative values in western hemisphere.
% 
% See also POS2STR DEG2NUM DEG2CART

%D=size(LON); LON=LON(:);

w=find(lon>180); 
%e=find(LON<=180); 
lon(w)=lon(w)-360;
%lon=lon([w;e]);
%mean=mean(:,:,[w;e]);

%lon=reshape(lon,D);
