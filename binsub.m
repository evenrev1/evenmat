function bin = binsub(inbin,j,i,k)
% BINSUB	Extract subset of binned field (binNd)
% 
% bin = binsub(inbin,j,i,k)
% 
% inbin	= structural of binned data from any of the BINnD
% j,i,k = indices pointing to gridpoints to extract for the different
%         dimensions of the fields (default=all).
%
% bin	= the output structure with all the relevant fields altered
%         according to the input indices.
% 
% Note that i is for the first dimension of the array/matrix, but
% relates to the y direction and is the second input to BIN2D and
% BIN3D. For consistency it is second input to this function also
% (sorry for the inconvenience).
%
% Note also that the locator fields .p and .s are removed in this
% process, since the grid-position of the originaly binned data is not
% related to the subset.
%
% This is a function in the bin-mean toolbox.
% 
% See also BIN1D

%Time-stamp:<Last updated on 03/08/31 at 21:25:36 by even@gfi.uib.no>
%File:</home/janeven/matlab/evenmat/binsub.m>

% Example structure
%        p: [1755x160 double] *
%        n: [101x160 double]
%     mean: [101x160 double]
%      var: [101x160 double]
%      min: [101x160 double]
%      max: [101x160 double]
%        x: [1x160 double]
%        y: [1x101 double]
%       xg: [1x161 double]
%       yg: [1x102 double]
%        i: [1755x160 double] *

error(nargchk(1,4,nargin));
[M,N,O]=size(inbin.mean);
if nargin<4|isempty(k), k=1:O; end
if nargin<3|isempty(i), i=1:M; end
if nargin<2|isempty(j), j=1:N; end

bin.n=inbin.n(i,j,k);
bin.mean=inbin.mean(i,j,k);
bin.var=inbin.var(i,j,k);
bin.min=inbin.min(i,j,k);
bin.max=inbin.max(i,j,k);
bin.x=inbin.x(j);
bin.xg=inbin.xg(j);

if isfield(inbin,'y')
  bin.y=inbin.y(i);
  bin.yg=inbin.yg(i); 
end
if isfield(inbin,'z')
  bin.z=inbin.z(k);
  bin.zg=inbin.zg(k); 
end
