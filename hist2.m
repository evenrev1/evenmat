function [n,X,Y,plevel] = hist2(x,y,X,Y,pp)
% HIST2	2D histogram
% Finds number of values distributed in the bins of a 2D grid
%
% [n,X,Y,plevel] = hist2(x,y,X,Y,pp)
% 
% x,y    = vectors or matrices of data to distribute
% X,Y    = bin-specifications for the two dimensions separately
%          (default: 10-by-10 bin structure over the ranges of x and y)
%          See BUILDGRID on how to specify!
% pp     = fraction of total number for plevel output (default=0.75). 
% 
% n      = the matrix of numbers of data in each bin
% plevel = the level which the sum of bin values that are higher
%          represent a pp fraction of the total data (to enable
%          contours drawn in X,Y-space around the pp fraction of data).
%
% If no output is specified, a plot will be given using PCOLOR
% 
% See also HIST BUILDGRID PCOLOR

error(nargchk(2,5,nargin));
% default number of bins
% if nargin<4 | isempty(Y), mima(x); Y=ans(1):diff(ans)/(m-1):ans(2); end
% if nargin<3 | isempty(X), mima(y); X=ans(1):diff(ans)/(m-1):ans(2); end
if nargin<5 | isempty(pp), pp=0.75; end
if nargin<4 | isempty(Y), Y=10; end
if nargin<3 | isempty(X), X=10; end

[X,XG] = buildgrid(X,x(:));
[Y,YG] = buildgrid(Y,y(:));

%X=sort(X);	Y=sort(Y);
N=length(XG);	M=length(YG);

%[XX,YY] = meshgrid(X,Y);
%[M,N] = size(X);

for j=1:N-1
  for i=1:M-2
    find(XG(j)<=x & x<XG(j+1) & YG(i)<=y & y<YG(i+1)); 
    n(i,j)=length(ans);
  end
  i=M-1;
  find(XG(j)<=x & x<=XG(j+1) & YG(i)<=y & y<=YG(i+1)); 
  n(i,j)=length(ans);
end
i=M-1;j=N-1;
find(XG(j)<=x & x<=XG(j+1) & YG(i)<=y & y<=YG(i+1)); 
n(i,j)=length(ans);

if nargout==0
  fig hist2 4;
  h=epcolor(X,Y,n);
    %set(gca,'xtick',XG,'ytick',YG);
  %xlabel x; ylabel y;
  colorbar;
end

if nargout>3 % calculate the level
  lev=sum(sum(n))*pp;
  ns=flipud(sort(n(:)));
  find(cumsum(ns)<lev);
  plevel=ns(ans(end)); % the last and next
  %plevel=mean([ns(ans(end)),ns(ans(end)+1)]); % the last and next
end

