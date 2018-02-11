function [sx,sy]=twine(x,y)
% TWINE         smooth chaotic data into an ordered one-to-one line
% Twines (tvinner sammen) any two-vector linespecification by sorting along
% the first dimension (x) and bin-averaging any values at approximately*
% same x-positions, so as to create a one-to-one function along one axis.
%
% [sx,sy]=twine(x,y)
%
% x  (alone) = 2xN or Mx2 matrix to be sorted based on first row/column
% x,y        = vectors describing the line, x being the basis of sorting 
%              (time, distance etc.) 
%
% sx (alone) = twined function as 2xN matrix
% sx,sy      = twined function in separate vectors 
%              (both shaped according to their respective inputs) 
%
% No output arguments results in a plot of the original- and the twined
% vector.
%
% EXAMPLE 1:     x=[1:3 3 3:7 7.1 7.3 7:12]; y=randn(size(x)); twine(x,y);
%
% EXAMPLE 2:     x=cumsum(rand(1,100));  y=randn(size(x)); twine(x,y);
%
% EXAMPLES OF APPLICATION...
% A contour specification of a density surface is not always a single line
% along a section, it might have loops and pinched off circles. TWINE
% "twines" the contour into a one-to-one function along the section, ready
% to be analysed further.   
% 
% TWINE is also a Q&D way of sorting a randomly distributed (1D) dataset,
% since it sorts along x and bins close positioned data. 
%
% * : The approximation is based on distribution of step-sizes. Any step
%     less than 1/2 of the median step-size, is considered to be
%     coinciding. The x-position is also averaged. This prevents the
%     occurrence of extremely short steps. 
%
% PS! BIN1D might be a more robust routine for this purpose!
%
% See also BIN1D CONTOURS SORTROWS

%Time-stamp:<Last updated on 06/09/14 at 11:31:54 by even@nersc.no>
%File:</home/even/matlab/evenmat/twine.m>

error(nargchk(1,2,nargin));
if nargin==1                        % checking input format
  [M,N]=size(x);
  if     M>N & N==2, mx=M; my=M;  x=x';
  elseif M<N & M==2, mx=1; my=1;
  else               error('Single input must be a 2xN or Mx2, matrix!');
  end
elseif isvec(x) & isvec(y) & length(x)==length(y)
  [mx,nx]=size(x); [my,ny]=size(y);
  if     mx==1 & my==1, M=2;  N=nx;       % - -
  elseif nx==1 & ny==1, M=mx; N=2;        % | |
  else                  M=2; N=length(x); % - |
  end
  x=x(:); y=y(:); x=[x,y]';
else
  error('Double input must be vectors of equal length!');
end

xx=delrow(find(isnan(x(1,:)')),x'); % find nans in the positions,
xx=delrow(find(isnan(x(2,:)')),x'); % find nans in the data
                                    % and remove those datapoints

sx=sortrows(xx,1)';                 % Sort on first row/column
df=diff(sx(1,:));                   % All steps less than 1/2 the median
tol=median(df(find(df>0)))/2;       % step are considered to be approx=zero
                                    % when finding ...
ii=[find(floor(df/tol)~=0) length(sx)]; %  ... indices for final sx 

a=diff(ii);                         % Where multiperiods start in 'ii' (-1)
pos=find(a>1);                      % Where in 'a' are they?
first = ii(pos)+1;                  % Indices of multiper startpoints
last  = ii(pos+1);                  % Indices of multiper endpoints
for i=1:length(pos)                 % Binmean values in each multiperiod
                                    % into the periods' end index
  sx(:,last(i))=mean(sx(:,first(i):last(i))')';
end
sx=sx(:,ii);                        % Reduce x to selected indices

if nargout==0                       % formatting output
  fig twine 4;
  plot(x(1,:),x(2,:),'k-o',sx(1,:),sx(2,:),'-r^');
  legend('input series','"twined" series',['Std.step = ',num2str(tol*2)],0); 
  grid on; zoom xon;
elseif nargout==1
  if M>N | (mx~=1 & my~=1), sx=sx'; % transpose to Mx2 matrix
  end
elseif nargout==2
  sy=sx(2,:); sx=sx(1,:);           % separate rows
  if mx~=1, sx=sx(:); end           % transpose x-vector
  if my~=1, sy=sy(:); end           % transpose y-vector
end





