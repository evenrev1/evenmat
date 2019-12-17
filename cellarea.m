function A = cellarea(lat,lon)
% CELLAREA	Area of grid cells
% The area of each grid cell is calculated as the surface
% area of latitude-longitude quadrangle on a grs80 reference
% ellipsoid. This area matrix is used for all area weighting.
% 
% A = cellarea(lat,lon)
% 
% lat	vector/matrix of grid latitudes as midpoints of cells
%	(changing long columns).
% lon	vector/matrix of grid longitudes as midpoints of cells
%	(changing long columns).
%
% A	Area matrix corresponing to input matrices [m^2]
%
% See also 

if isvector(lon) & isvector(lat)
  %[lat,lon]=meshgrid(lat,lon);
  [lon,lat]=meshgrid(lon,lat);
end

[M,N]=size(lon);
% create AREA grid
A=nans(M,1); j=1; dl=lat(2,1)-lat(1,1);
for i=1:M
  A(i,j)=areaquad(lat(i,j)-dl/2,lon(i,j),lat(i,j)+dl/2,lon(i,j+1), ...
		  referenceEllipsoid('grs80','kilometers')); 
end
% For lon it does not matter that we use the centerpoints here
% A size equals z size
A=repmat(A,1,N)*1e6;  % km2 -> m2

