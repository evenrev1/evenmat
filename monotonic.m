function [x,IC]=monotonic(x,sign)
% MONOTONIC	Make input monotonic
% by recursively changing any value higher than the next value to be
% equal to this next value. Since there are equal values the result is not
% strictly monotonic. Remember that outliers are judged by their relation
% to their next value, not the previous.
%
% [x,IC] = monotonic(x,sign)
%
% x	= input vector or matrix 
% sign	= increasing (1) or decreasing (-1). By default the relation
%         between the first and last value decides whether the function
%         is increasing or decreasing. 
%
% x	= input vector or matrix with only monotonic values
% IC	= logical vector or matrix true for the changed, non-
%	  monotonic values in x 
%
% Output will be monotonic along columns.

%Time-stamp:<Last updated on 06/09/14 at 11:31:37 by even@nersc.no>
%File:</home/even/matlab/evenmat/monotonic.m>

if isvec(x)==2, x=x(:); end

[M,N]=size(x);

if M==0, return; end

IC=false(M,N); % Init logical matrix for changes 
ox=x; % save for plot

if nargin<2|isempty(sign)
  %~isnan(x)
  %ans([1 end],:)
  %x(ans)
  %diff(ans)
  %  sign(ans<0)=-1; sign(ans>=0)=1
  sign=ones(1,N)*1; % Default = increasing
else
  sign=ones(1,N)*sign;
end

% if nargin<2|isempty(sign)
%   if X(1)<=X(end),	sign=1;		% assume increasing
%   else		sign=-1; end	% assume decreasing
% end


for j=1:N                               % Loop through columns
  i=find(~isnan(x(:,j)));		% Omit nans
  if ~isempty(i),			% Have to have some data
    X=x(i,j);				% The column in question
    dx=find(sign(j)*diff(X)<0);		% Find all wrong way steps
    while any(dx)			% As long as next is 
      X(dx(1))=X(dx(1)+1);		% Assign the next value to the first wrong step
      dx=find(sign(j)*diff(X)<0);	% Find all new remaining wrong way steps
    end
    IC(i,j) = x(i,j)~=X(i,j);		% Assign true for the changed (i.e., different) values
    x(i,j)=X;				% Replace column
  end
end

if nargout==0           % Plotted output
  fig monotonic 34; clf; 
  plot(1:M,ox,'bo-',1:M,x,'g.-',find(IC),x(IC),'ro');
  legend('Data','Monotonic output','Changed points','Location','best'); 
  title('Monotonic');
  set(gca,'xtick',1:M,'xgrid','on','ygrid','on');
end
