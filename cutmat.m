function y=cutmat(x,i,dim)
% CUTMAT	cuts out specified part of arbitrary size array 
% Regardless of array size, indices in a specific dimension can be given
% to extract parts of array.
% 
% y = cutmat(x,i,dim)
% 
% x	= input array
% i	= vector of indices at which to extract data
% dim	= single number giving the dimension along which to apply the
%	  indices in i (default = 1)
%
% y	= the resulting piece of the array
%
% EXAMPLE: To extract levels 3,4, and 7 from a 3D array, the syntax is
% x([3,4,7],:,:), but if the size of the array is arbitrary (as might happen
% with input to functions) the number of ",:" is unknown. But you can cut
% data with same indices along the first dimension in any array, using
% CUTMAT(x,[3,4,7],1).  See ANOMALY for example of practical use.
%
% See also COLON REPMAT RESHAPE

%Time-stamp:<Last updated on 02/05/03 at 14:01:49 by even@gfi.uib.no>
%File:<~/matlab/cutmat.m>

error(nargchk(2,3,nargin));
if nargin<3 | isempty(dim),	dim=1;	end

D=size(x);
s1 = repmat(':,',1,dim-1);
s2 = repmat(',:',1,length(D)-dim);

['y=x(',s1,'i',s2,');'];
eval(ans);

if ~nargout, disp(ans);	end
