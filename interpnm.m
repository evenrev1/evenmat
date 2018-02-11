function [Y,dx,dy]=interpnm(x,y,X,opt)
% INTERPNM	Interpolation of non-monotonic functions
%
% [Y,dx,dy] = interpnm(x,y,X,opt)
%
% x     = vector specifying positions of the data in ...
% y     = vector of data-values
% X     = vector of points to interpolate onto
% opt	= option character:
%	     's' : only one single crossing desired despite single X
% 
% Y     = the values of the underlying function y at the points in the
%         vector X in a length(X)-by-size(y,2) matrix, using the hit
%         furthest out in the vectors when non-monotonicities occur.
%
% dx,dy = The SIGN (+1/-1) of the increment in x and y respectively, 
%         at the corresponding crossing in Y.
%
% If y is a matrix or array, the interpolation is performed for each column
% of y and Y will be length(X)-by-... . Out of range values are returned as
% NaNs. If X is single, the columns of the output Y will contain all
% crossings of the function y with this value.
%
% ROUTINE: Splits up x and y into monotonically increasing segments, and
% does INTERP1Q on each segment, using last segment first and searching
% forward until all possible crossings with the points in X are found.
%
% One practical purpose of this is in searching for isopycnal levels in
% profiles containing instabilities. The deepest point with chosen density
% is found. Another is to find crossings (zero- or other) of a timeseries.
%
% No output argument results in a plot of the original- and the filtered
% vector together.
%
% See also INTERP1Q INTERPWP INTERPLOG

%Time-stamp:<Last updated on 12/10/24 at 20:32:39 by even@nersc.no>
%File:</Users/even/matlab/evenmat/interpnm.m>

error(nargchk(3,4,nargin));
if nargin<4 | isempty(opt),	opt=' ';	
else				opt=opt(1);	end

if	isvec(x)==2,		x=x'; end
if	isvec(y)==2,		y=y'; end
if	isvec(x)&~isvec(y), x=repmat(x(:),[1,size(y,2),size(y,3)]);   
elseif	isvec(y)&~isvec(x), y=repmat(y(:),[1,size(x,2),size(x,3)]);   
end

D=size(y); cols=prod(D(2:end));
if size(y,1)~=D(1)
  error('x and y must have same number of rows!');
end

if isvec(X)==2, X=X'; end

M=size(X,1);		% 1st dimension of output
[Y,dx,dy]=deal(nans(M,cols));		% Init output (preallocate memory)

for j=1:cols		% LOOP through columns (works also for arrays)
  find(~isnan(x(:,j)) & ~isnan(y(:,j)));	% Find non-nan values
  xx=x(ans,j); yy=y(ans,j); mm=length(ans);	% for col-local vectors
  if mm>1
    % segmentation-vector is turning-points and series' ends:
    seg=[1; find(diff(xx(1:end-1)).*diff(xx(2:end))<=0)+1 ;mm];
    for i=0:length(seg)-2		% LOOP each segment
      ii=seg(end-i-1):seg(end-i);	% last to first, finding ...
      [xxx,iii]=sort(xx(ii));		% (make segment increasing)
      yyy=yy(ii(iii));
      II=isnan(Y(:,j));			% ... the not before found
      if any(II) & M>1			% more than one X to find
	Y(II,j)=interp1q(xxx,yyy,X(II)); 
      elseif any(II) & M==1		% only one X to find (first)
	find(II); Y(ans(1),j)=interp1q(xxx,yyy,X(:));
      elseif ~any(II) & M==1 & opt~='s' % only one X to find (more hits?)
	%Y(end+1,:)=nan;	% NaN-fill instead of the automatic zeros
	interp1q(xxx,yyy,X(:)); if ~isnan(ans), Y(end+1,j)=ans; II=length(Y);end
      end
      dx(II,j)=sign(diff(xx(ii(1:2)))); % direction of segment
      dy(II,j)=sign(diff(yy(ii(1:2)))); % direction of segment
    end
  end
end

if nargout==0 & cols==1          % Plotted output if single profile
  fig interpnm 34; clf; 
  plot(x,y,'bo-',X,Y,'g.-');
  legend('Data','Interpolation',0); 
  title('Interpolation of Non-Monotonic functions');
  set(gca,'xtick',X,'xgrid','on');
end

M=size(Y,1);			% 1st dimension of output
Y=reshape(Y,[M D(2:end)]);	% Reshape output, matrix->array

%Y=flipud(Y);			% flip since it starts at "bottom"
% this gave trouble ??? check out later if necessary.
