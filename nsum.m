function [y,N] = nsum(x,dim)
% NSUM  Sum ignoring NaNs (w/choice of dimension)
%
%   NSUM(X) returns the sum treating NaNs as missing values.  
%   For vectors, NSUM(X) is the sum of the non-NaN elements in
%   X. For matrices, NSUM(X) is a row vector containing the sum 
%   of the non-NaN elements in each column of X. 
%  
%   NSUM(X,DIM) sums along the dimension DIM. 
%
%   A second output is possible, giving the number of non nan values
%   in each sum. Could be handing for averageing purposes.
% 
%   See also NANMEDIAN, NANSTD, NMEAN.

% Yes, this is a dirty hack of statistics toolbox' NANSUM, but hey,
% that code anyone could have made, and they did forget to port
% the dimension option of SUM.

%Time-stamp:<Last updated on 12/08/09 at 14:29:32 by even@nersc.no>
%File:</Users/even/matlab/evenmat/nsum.m>

error(nargchk(1,2,nargin));
if nargin<2 | isempty(dim), dim=1; end

% Replace NaNs with zeros.
N=sum(~isnan(x),dim);
nans = isnan(x);
i = find(nans);
x(i) = zeros(size(i));

% Protect against an entire column of NaNs
y = sum(x,dim);
i = find(all(nans,dim));
y(i) = i + NaN;  % What was zero, becomes nan. i is just a matrix of
		 % the right size.

