function ZG = efill(Z,opt);
% EFILL	Interpolation on NaN datapoints.
% 
% ZG = efill(Z,opt)
%
% Z	= input matrix
% opt	= options for interpolation method (default='linear'; see GRIDDATA)
%
% Uses griddata to simply interpolate to fill NaNs in a matrix.
%
% See also GRIDDATA INTERP MESHGRID EXTRAP

error(nargchk(1,2,nargin));
if nargin<2 | isempty(opt),	opt='linear';	end

[X0,Y0]=meshgrid(1:size(Z,2),[1:size(Z,1)]');
ZNN=Z(~isnan(Z));
YNN=Y0(~isnan(Z));
XNN=X0(~isnan(Z));
ZG = griddata(XNN,YNN,ZNN,X0,Y0,opt);


