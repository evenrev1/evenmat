function [Z,LO,LA] = gridsort(lon,lat,z,LO,LA)
% GRIDSORT sorts gridded but not 2D shaped input data into 2D. 
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
% [Z,LO,LA] = gridsort(lon,lat,z,LO,LA)
% 
% lon,lat = vectors describing lon and lat position of gridded data.
% z       = ND array of original data with space as first dimension
%           (corresponding lon and lat), and any other
%           dimensions following (e.g., time).
% LO,LA   = 1D vectors describing the grid. 
%           Give input if grid is known a priori. If not, the range
%           and minimum differences of lon and lat will be used to
%           form the 2D grid, using MESHGRID.
%
% Z       = The new 2D matrix or ND array of the input variable, with
%           first two dimensions as LA and LO, and the further
%           dimensions as in input z, beginning with the 2nd (e.g.,
%           time).
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

error(nargchk(3,5,nargin));
if nargin<4, % create target grid
  do=min(diff(unique(lon)));
  da=min(diff(unique(lat)));
  [LO,LA]=meshgrid(min(lon(:)):do:max(lon(:)),min(lat(:)):da:max(lat(:))); 
else
  [LO,LA]=meshgrid(LO,LA); 
end

D=size(z);
if D(1)>1 & (~isvec(lon) | ~isvec(lat)) | length(lon)~=length(lat) | D(1)~=length(lat) 
  error('Input data must match!')
end

[M,N]=size(LO);
[ans,IA,IB]=intersect([LA(:),LO(:)],[lat(:),lon(:)],'rows','stable'); 
				% Stack lon,lat coordinates of both grid
                                % and input positions, and find
                                % corresponding rows in the grid stack.
                                % ans = A(IA)
Z=nans([M*N,D(2:end)]);		% Predefine output data, with space as rows
s = repmat(',:',1,length(D)-1);	% Make string for the further dimensions
eval(['Z(IA',s,')=z(IB',s,');']);% Put input data in the right rows of grid
Z=reshape(Z,[M,N,D(2:end)]);	% Reshape output data space into matrix 

if nargout<1
  figure;
  s = repmat(',1',1,length(D)-1);
  eval(['pcolor(LO,LA,Z(:,:',s,'));']);
  shading flat;
end
