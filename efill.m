function VG = efill(V,opt);
% EFILL	Interpolation on NaN datapoints.
% 
% VG = efill(V,opt)
%
% V	= input array (or vector for 1D)
% opt	= options for interpolation method (default='linear'; see
%         GRIDDATA for array and INTERP1 for vector)
%
% Uses griddata to simply interpolate to fill NaNs in a matrix.
%
% See also GRIDDATA INTERP MESHGRID EXTRAP

error(nargchk(1,2,nargin));
if nargin<2 | isempty(opt),	opt='linear';	end

D=size(V);
switch length(find(D>1)) %ndims(V)
 case 1
  X0=1:max(D);
  VNN=V(~isnan(V));
  XNN=X0(~isnan(V));
  VG = interp1(XNN,VNN,X0,opt);
 case 2
  %[X0,Y0]=meshgrid(1:size(V,2),[1:size(V,1)]');
  [X0,Y0]=meshgrid(1:D(2),[1:D(1)]');
  VNN=V(~isnan(V));
  YNN=Y0(~isnan(V));
  XNN=X0(~isnan(V));
  VG = griddata(XNN,YNN,VNN,X0,Y0,opt);
 case 3
  [X0,Y0,Z0]=meshgrid(1:D(2),[1:D(1)]',1:D(3));
  VNN=V(~isnan(V));
  ZNN=Z0(~isnan(V));
  YNN=Y0(~isnan(V));
  XNN=X0(~isnan(V));
  VG = griddata(XNN,YNN,ZNN,VNN,X0,Y0,Z0,opt);
end


