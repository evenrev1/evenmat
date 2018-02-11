function [Y,D]=interplog(x,y,X,opt)
% INTERPLOG     Logarithmic interpolation 
%
% [Y,D] = interplog(x,y,X,opt)
%
% x     = vector specifying positions of the data in ...
% y     = vector of data-values
% X     = vector of points to interpolate onto
% opt   = option-string containing any of the following:
%               'near'  - Use neighbour extrapolation to chosen points
%                         close to the last sample (within 15% of gap to
%                         previous interpolation point (X)). 
%                         Only at deep end.
%
% Y     = the values of the underlying function y at the points in the
%         vector X in a length(X) x size(y,2) matrix.
% D     = Array of interpolation neighbours (size(Y) x 2) with neighbours
%         before and after X in first and second layer respectively.
%
% Fofonoff,N.P. (1962). Machine computations of mass transport in the
% North Pacific Ocean. journal of Fishery Research Board Canada, v.19,
% p.1121-1141.
%
% See also INTERPWP INTERP1

%Time-stamp:<Last updated on 06/09/14 at 11:31:33 by even@nersc.no>
%File:</home/even/matlab/evenmat/interplog.m>

if nargin<5|isempty(xd),        xd=[];                  end % Interp. limit
if nargin<4|isempty(opt),       opt=[];                 end % Option string
if nargin<3|isempty(x),         mima(x); X=ans(1):diff(ans)/30:ans(2); end
if nargin<2,                    [x,y,X]=example;
                                disp('Example interpolation'); end

if      isvec(y),    y=y(:); x=x(:);                 % column vector
elseif  isvec(x),    x=repmat(x(:),1,size(y,2));     % matrix data
end

M=length(X);            % the number of interpolation points
N=size(y,2);            % the number of columns in data

for j=1:N               % LOOP through all columns (profiles/stations)
  ii=find(~isnan(y(:,j))&~isnan(x(:,j)));% "Send in" only non-nan data
  xx=x(ii,j); yy=y(ii,j);
  for i=1:M             % LOOP through specified X's
    [x1,x2,I1,I2]=neighbours(xx,X(i));
    D(i,j,:)=[x1,x2];                   % Output-array of neighbours
    %Dp=xx(end)-xx(1);                  % difference of profiles' ends
    %De=X(i)-xx(end);                   % extrapolation? difference
    if x1==x2                           % RIGHT ON an existing value
      Y(i,j)=yy(I1);
    elseif length(yy)>1 & isnan(I1) & i>1 ...
          & any(findstr(opt,'near')) ...
          & (X(i)-xx(end))/(X(i)-X(i-1)) < .15 ...
          & (X(i)-xx(end))>0 
      %  & Dp>De
      % OUTSIDE range but CLOSE => lin-extrapol based on profiles' ends
      % Y(i,j)=(yy(end)-yy(1))/Dp*De+yy(end);
      Y(i,j)=yy(end);
    elseif isnan(I1)                     % NOT CLOSE enough => NaN
      Y(i,j)=nan;
    else                                % Between existing values => LOGINT
      Y(i,j)=(yy(I2)-yy(I1))* log10((X(i)+10)/(x1+10)) / ...
                                log10((x2  +10)/(x1+10)) + yy(I1);
    end
  end
end

if nargout==0,                          % Plotted output
  fig interplog 34; clf;
  plot(x,y,'bo-',X,Y,'g.-'); 
  legend('Original data','Interpolated values');
  title('Logarithmic interpolation');
  set(gca,'xtick',X,'xgrid','on');
end


%----------------------------------------------------------------
function [od,oT,id]=example()
% standarddepth (interpolation depth)
id=[0 10 20 30 50 75 100 125 150 175 200 250 300 400 500 600 700 800 1000];
% depth:
od=[0 10 20 30 50 75 100 125 150 175 200 250 300  395 498 748 998 1000];
% Temp:
oT=[1310 1305 1210 1170 946 833 805 790 778 751 704 636 583 512 449 390 ...
    329 329]/100;

