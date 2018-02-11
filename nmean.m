function y = nmean(x,dim)
% NMEAN  Mean ignoring NaNs (w/choice of dimension)
%
%   NMEAN(X) returns the mean treating NaNs as missing values.  
%   For vectors, NMEAN(X) is the sum of the non-NaN elements in
%   X. For matrices, NMEAN(X) is a row vector containing the sum 
%   of the non-NaN elements in each column of X. 
%  
%   NMEAN(X,DIM) means along the dimension DIM. 
% 
%   See also NANMEDIAN, NANSTD, NSUM.
%
%   Requires NSUM

%Time-stamp:<Last updated on 06/11/14 at 10:56:47 by even@nersc.no>
%File:</Home/even/matlab/evenmat/nmean.m>

error(nargchk(1,2,nargin));
if nargin<2 | isempty(dim), dim=1; end

data = ~isnan(x);  % array with ones where x is non-nan 
N=nsum(data,dim);  % array of size(y) with numbers of non-nans 
N(N==0)=nan;       % Secure against all-nan rows/columns
                   % (i.e. against division by zero)            
y=nsum(x,dim)./N;  % sum ignoring nans / actual number of non-nans

