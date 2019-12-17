function [Z,LO,LA,T] = gridsort3(lon,lat,t,z)
% GRIDSORT sorts gridded but not 3D shaped input data into 3D. 
%
% Some times even gridded data are given as vectors and not matrices,
% often omitting empty gridpoints and with no particular known sorting
% of positions (making simple RESHAPE impossible). In order to compare
% and calculate using such data, it can be desireable to have the
% spatial fields in 2D matrix format. GRIDSORT does this by sorting the
% data into its appropriate gridcells of the full 2D grid spanned by the
% original grid. This is both faster and more clean cut than attempting
% any interpolation to fix the problem.
% 
% [Z,LO,LA,T] = gridsort3(lon,lat,t,z,LO,LA)
% 
% lon,lat = vectors describing lon and lat position of gridded data.
% t	  = vector for the third dimension, 
% z       = ND array of original data with space as first dimension
%           (corresponding lon and lat), and any other
%           dimensions following (e.g., time).
%
% Z       = The new 3D matrix or ND array of the input variable, with
%           first two dimensions as LA and LO, and the further
%           dimensions as in input z, beginning with the 2nd (e.g.,
%           time).
% LO,LA   = 3D matrices describing the grid, with latitude as 1st
%           dimension (along column) and longitude as 2nd. 
%           Give input if grid is known a priori. If not the range
%           and minimum differences of lon and lat will be used to
%           form the 2D grid, using MESHGRID.
% T	  = matrix of the third dimension, e.g., time.
%
% Remember, this is not interpolating or bin averageing, grid
% positions must match exactly. GRIDSORT works on arrays of any
% sizes, ignoring the shape beyond the first dimension (which is
% assumed to be space).
%
% If no output is requested, GRIDSORT will plot the first spatial
% field of Z using PCOLOR, for testing. 
%
% See also INTERSECT MESHGRID

error(nargchk(4,6,nargin));
if nargin<5 % create target grid
  do=min(diff(unique(lon)));
  da=min(diff(unique(lat)));
  dt=min(diff(unique(t)));
  [LO,LA,T]=meshgrid(min(lon(:)):do:max(lon(:)),min(lat(:)):da:max(lat(:)),min(t(:)):dt:max(t(:))); 
end

D=size(z);
if ~isvec(lon) | ~isvec(lat) | ~isvec(t) ... 
      | length(lon)~=length(lat) | length(lon)~=length(t) ... 
      | D(1)~=length(lat) 
  error('Input data must match!')
end

[M,N,O]=size(LO);
[ans,IA,IB]=intersect([LA(:),LO(:),T(:)],[lat(:),lon(:),t(:)],'rows','stable');
				% Stack lon,lat coordinates of both grid
                                % and input positions, and find
                                % corresponding rows in the grid stack.
                                % ans = A(IA)
Z=nans([M*N*O,D(2:end)]);		% Predefine output data, with space as rows
s = repmat(',:',1,length(D)-1);	% Make string for the further dimensions
eval(['Z(IA',s,')=z(IB',s,');']);% Put input data in the right rows of grid
Z=reshape(Z,[M,N,O,D(2:end)]);	% Reshape output data space into matrix 

if nargout<1
  figure;
  s = repmat(',1',1,length(D)-1);
  eval(['pcolor(LO(:,:,1),LA(:,:,1),Z(:,:,1',s,'));']);
  shading flat;
end
