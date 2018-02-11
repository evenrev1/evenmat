function [x,y]=deg2cart(lon,lat,origo,angle);
% DEG2CART      lon/lat coordinates into cartesian km-coordinates 
% with origo at a given position. The polar coordinates are found by
% calculating distances and bearings from origo using the "Plane Sailing"
% method, then these polar coordinates are (rotated and) converted into
% cartesian coordinates.
%
% [x,y] = deg2cart(lon,lat,origo,angle)
%
% lon,lat = vectors or matrices of positions in degrees
% origo   = [lon lat] desired position of cartesian axes
% angle   = angle to rotate axes (counterclockwise from 0=eastward) 
% x,y     = vectors or matrices of the cartesian coordinates in km
%
% See also SW_DIST POL2CART DEG2NUM POS2STR

%Time-stamp:<Last updated on 04/02/18 at 14:05:30 by even@nersc.no>
%File:</home/even/matlab/evenmat/deg2cart.m>

error(nargchk(2,4,nargin));
if nargin<4 | isempty(angle),	angle=0;			end
if nargin<3 | isempty(origo),	lo0=0;		la0=0;
else				lo0=origo(1);	la0=origo(2);	end

[M,N]=size(lon);			% remember original shape
if [M,N]~=size(lat), error('lon and lat must be of equal size!'); end
lon=lon(:); lat=lat(:);	n=length(lat);	% Reshape to column vectors
repmat(lo0,1,n); [ans;lon']; lo=ans(:);	% Put origos in between lon
repmat(la0,1,n); [ans;lat']; la=ans(:);	% Put origos in between lat
[r,a]=sw_dist(la,lo,'km');		% Calc distances forth and back
					% r = length (radius)
					% a = alpha (x-aksis angle,
                                        %           counterclockwise, 0=east)
reshape([r;999],2,n); r=ans(1,:);	% Pick out every other dist (forth)
reshape([a;999],2,n); a=ans(1,:);	% Pick out every other angle
a = a + uminus(angle);			% Rotate axes
%[x,y] = pol2cart(deg2rad(a),r);	% Transform from polar to cartesian
[x,y] = pol2cart(a*pi/180,r);		% Transform from polar to cartesian
x=reshape(x,M,N);   y=reshape(y,M,N);	% Shape (output = input)


% x
%lo=[lo0;lon];
%dist=sw_dist(la0*ones(size(lo)),lo,'km'); % get distances between points
%fortegn=sign(diff(lo)); % 1, 0 or -1      % in what direction is next point
%x=cumsum(dist.*fortegn);                  % cumulative sum with sign gives
                                           % position 
% y
%la=[la0;lat];
%dist=sw_dist(la,lo0*ones(size(la)),'km');
%fortegn=sign(diff(la)); % 1, 0 or -1     
%y=cumsum(dist.*fortegn);                 

