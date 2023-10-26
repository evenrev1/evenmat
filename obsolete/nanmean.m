function [y,n]=nanmean(x,dim)
% NANMEAN       a MEAN that tolerates (ignores) NaNs in the input
%
% [y,n] = nanmean(x,dim)
%
% x    = input array
% y    = the mean values
% n    = the actual sample sizes for the means (i.e. less the NaNs)
%
% See also MEAN

% Last updated: Fri Oct 20 12:57:12 2023 by jan.even.oeie.nilsen@hi.no

error(nargchk(1,2,nargin));
if nargin < 2 | isempty(dim), dim=1; end

N=ndims(x);		% Number of dimensions of input array

if dim>N, error(['Selected dimension ',num2str(dim),' is larger than the number of dimensions of x!']); end

nx=~isnan(x);		% Identical size logical with true for numbers

x=shiftdim(x,dim-1);	% so that dim becomes first dimension (columns)
nx=shiftdim(nx,dim-1);	% so that dim becomes first dimension (columns)

y=mean(x,1);		% Mean along the first dimension (columns)

n=sum(nx);		% Sample sizes for all means 

I=find(isnan(y));	% Indices to columns that had NaNs

for i=1:length(I) % Loop columns and for each column with any nans take
                  % mean using only the non-nans in that column and put
                  % as the I-th mean value:
  y(I(i))=mean(x(nx(:,I(i)),I(i)));
end

y=shiftdim(y,N-dim+1); % back to the original dimensions of x
n=shiftdim(n,N-dim+1); % back to the original dimensions of x

