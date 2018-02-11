function y=sortrows3(x,k)
% SORTROWS3	Sort 3D array along 3d dimension 
%
% y = sortrows3(x,k)
%
% x	= 3D array to be sorted 
% k	= layer in 3d dimension to sort by
% y	= the sorted array
%
% Each (:,j,:)-layer is sorted separately by the specified column k. This
% routine is simply SORTROWS run on each (:,j,:)-layer separately.
%
% EXAMPLE: You have put P corresponding 2D-data-fields together in a
% M-by-N-by-P array (Salinity, Temperature and Depth => P=3). Each (i,j)
% datapoint of the fields belongs to the same sample. Sorting the data by
% depth is now easy. If depth is the third k-layer of the array, using
% data=SORTROWS3(data,3) sorts each column by depth and the Salinities and
% Temperatures follow their corresponding depths.
%
% See also SORTROWS SORT

%Time-stamp:<Last updated on 01/03/20 at 21:43:30 by even@gfi.uib.no>
%File:<d:/home/matlab/sortrows3.m>

error(nargchk(1,2,nargin));
if nargin<2 | isempty(k),	k=1;	end

y=nans(size(x));

for j=1:size(x,2)	% loop along columns j
  xx(:,:)=x(:,j,:);
  y(:,j,:)=sortrows(xx,k);
end
