function [b,a,Ib,Ia]=neighbours(x,X)
% NEIGHBOURS	find neighbouring points to a number in given vector
%
% [b,a,Ib,Ia] = neighbours(x,X)
%
% x	= vector to search in for neighbouring values to ...
% X	= the single specific value
%
% b   	= the nearest value before X in x
% a     = the nearest value after X in x
% Ib	= index in x of b
% Ia	= index in x of a
%
% If only one output argument is given, this will be formatted as the two
% value vector [b;a].
%
% If the result is a "direct hit" on a value in x, both b and a (Ib and Ia)
% will be assigned this value. Tests for direct hits might then be done by
% comparision of the b and a output.
%
% If a matrix is given as x, the search for neighbours will be done
% columnwise. The output will then be two row vectors b and a, or a
% 2-by-length(X) matrix [b;a].  A row-vector X, with one value for each
% column in a matrix x, can be given when neighbours of different values for
% each column of x is sought.
%
% This function finds neighbouring points in the _sequence_ of values in x
% (the points before and after), NOT neighbouring points according to the
% values in x (highest number below and lowest number above). If there are
% more than one "crossing" of X in x, the last crossing is chosen. The
% search ignores NaNs. 
%
% EXAMPLE: When interpolating to find a value, it might be interesting to
% know which neighbouring values the interpolation is based on.
%
% See also INTERP1 INTERPWP

%Time-stamp:<Last updated on 06/09/14 at 11:31:45 by even@nersc.no>
%File:</home/even/matlab/evenmat/neighbours.m>

error(nargchk(2,2,nargin));

if isempty(x)					% Test x
  [b,a,Ib,Ia]=deal(NaN); return;			
elseif isvec(x)==2
  x=x(:);		
end			
N=size(x,2);
						% Test X
if issingle(X)					% If single:
  X=repmat(X,1,N);				% duplicate value
elseif ~isvec(X)				% If matrix:
  error('Input X must be single or vector!');	% error
else						% If vector:
  if N~=length(X)				% test length
    error('Length of X must match number of columns in x!');
  end
end

[b,a,Ib,Ia]=deal(nans(1,N));		% preallocate memory

for j=1:N				% Loop through columns
  non=find(~isnan(x(:,j)));		% Find indices of non-nan-vector
  xx=x(non,j);				% Copy to non-nan-vector
  il=find(xx<=X(j));			% Find indices of values less
  ig=find(xx>X(j));			% Find indices of values greater
  if ~(isempty(non)|isempty(il)|isempty(ig)) % NOT(NO DATA or NO CROSSING)
    if xx(end)==X(j)			% The extra possibility that
      [b(j),a(j)]=deal(X(j));           % gives no tail (DIRECT HIT ON LAST)
      [Ib(j),Ia(j)]=deal(non(end));
    else				% Normal crossing
      ans(2)=max(ig); ans(1)=max(il);
      if ans(2)>ans(1),	ii=ans(1);	% Which has the end-tail?
      else		ii=ans(2); end	% The other has the ii as last
      b(j)=xx(ii);			% Assign the values
      a(j)=xx(ii+1);			% ( ii is index into xx )
      if b(j)==X(j)|a(j)==X(j)		% Check for DIRECT HITS in crossing
	if a(j)==X(j), ii=ii+1; end	% if it's the after, I must change
	[b(j),a(j)]=deal(X(j));		% Assign this value to both
	Ia(j)=non(ii);			% and Iafter is same as Ibefore
      else				% or 
	Ia(j)=non(ii+1);		% Iafter is the next
      end
      Ib(j)=non(ii);			% Ibefore in original input
    end		
  end
end 
% This last bit might seem a bit awkward, but it is necessary to find the
% end tail before checking for direct hits.

if nargout<2, b=[b;a]; end		% Format output
