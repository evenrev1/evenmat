function [Y,D,YR]=interpwp(x,y,X,m,n,eplim,opt)
% INTERPWP      Interpolation by Weighted Parabolas 
%
% [Y,D] = interpwp(x,y,X,m,n,iplim,opt)
%
% x     = vector specifying positions of the data in ...
% y     = vector of data-values
% X     = vector of points to interpolate onto
% m,n   = optional algorithm-parameters (described below)
% eplim = 
% opt   = option-string containing any of the following:
%               'near'  - Use linear extrapolation to chosen points
%                         outside but close to the last sample (within
%                         15% of gap to previous interpolation point (X))
%                         Only at deep end.
%               'copy'  - If lowest input value is deeper than 900, it
%                         will be copied down to 100 m below as if
%                         homogeneous water to avoid linear interpolation
%                         between the last two input values.
%
% Y     = the values of the underlying function y at the points in the
%         vector X in a length(X) x size(y,2) matrix.
% D     = Array of interpolation neighbours (size(Y) x 2) with neighbours
%         before and after X in first and second layer
%         respectively. Third layer consists of logical 1 for points
%         based on linear interpolation.
%
% If y is a matrix, then the interpolation is performed for each column of y
% and Y will be length(X)-by-size(y,2). Out of range values are returned as
% NaN.
%
% If x is not monotonic, it will be made monotonic before interpolation
% by the function MONOTONIC. Since this is not strictly monotonic, the
% interpolation will separate points of equal x-position slightly, to
% avoid division by zero. If you need y to be monotonic before
% interpolationg, like when interpolating density and instabilities are
% undesired, you need to use MONOTONIC on y first.
%
% ALGORITHM: The interpolation scheme is that of Reiniger & Ross (1968),
% which is a method of weighted parabolas, an extension of the work of
% Rattray (1962), who used an arithmetic mean of two parabolas. This method
% is considered to be especially suitable for vertical oceanic profiles, and
% deals well with the problem of the thermocline, by diminishing the
% "overshoot" effect of an unacceptable parabola.
%
% PARAMETERS: The parameter m is the exponent for reference
% curve. Recommended range is 1.5-2.0. Values of m < 1.5 gives overshoots,
% and m > 2 gives nearly linear curves. This function's default is m = 1.7,
% the authors' compromise. The parameter n is the exponent for the weighed
% estimate. Recommended range is 0.9-2.0, with the same results as m for
% outside values, with most acceptable curve obtained for n=0.9.
%
% Following the authors' advise, linear interpolation is applied at
% endpoints (interpolation-point inside only one data-value).
%
% An error estimate (an advantage of this method) will maybe be implemented
% later.
%
% R.F. Reiniger and C.K. Ross (1968). A method of interpolation with
%       application to oceanographic data. Deep Sea Research, 15,
%       p.185-193 
% Rattray, Jr, Maurice (1962). Interpolation errors and oceanographic
%       sampling.  Deep Sea Research, 9, p.25-37
%
% See also INERPLOG INTERP1 MONOTONIC

% Obsolete text:
% x monotonic: The effect of this on oceanic profiles is that any
% inversions will be neutralized, but their data not completely overlooked
% since it is used but with a value equal to the next (deeper) value.


%error(nargchk(3,5,nargin));
if nargin<7|isempty(opt),opt=[]; end % Option string
if nargin<6|isempty(eplim),  eplim=[5 900];  end % Limits allowing for data extrapolation
if nargin<5|isempty(n),  n=0.9;  end % Exponent for weighed estimate (0.9-2.0)
if nargin<4|isempty(m),  m=1.7;  end % Exponent for reference curve  (1.5-2.0)
if nargin<3|isempty(X),  mima(x); X=ans(1):diff(ans)/30:ans(2);       end
if nargin<2,             [x,y,X]=example;                             end

if      isvec(y),    y=y(:); x=x(:);                 % column vector
elseif  isvec(x),    x=repmat(x(:),1,size(y,2));     % matrix data
end

M=length(X);            % the number of interpolation points
N=size(y,2);            % the number of columns in data
id=diff(mima(y))/50;    % limit for gradient test (extrapolation)

for j=1:N               % loop through columns (profiles/stations)
  find(~isnan(y(:,j))&~isnan(x(:,j))); % "Send in" only non-nan data
  xx=monotonic(x(ans,j)); yy=y(ans,j);
  for i=1:M             % loop through each chosen depth
%     if ~isempty(xx) & max(xx)>eplim(2) & any(findstr(opt,'copy')) 
%       % The WP-interpolation with extra endpoint Q&D addition 
%       [Y(i,j),YR(i,j),D(i,j,:)]=oneF([xx;xx(end)+100],[yy;yy(end)],X(i),m,n);
%       if D(i,j,2)>xx(end), D(i,j,2)=nan; end	% Remove fake neighbour
    if ~isempty(xx) & eplim(1)>min(xx) & max(xx)>eplim(2) & any(findstr(opt,'copy')) 
      % The WP-interpolation with extra endpoint Q&D addition 
      [Y(i,j),YR(i,j),D(i,j,:)]=oneF([xx;xx(end)+100],[yy;yy(end)],X(i),m,n);
      if D(i,j,2)>xx(end), D(i,j,2)=nan; end	% Remove fake neighbour
    else
      % Standard WP-interpolation 
      [Y(i,j),YR(i,j),D(i,j,:)]=oneF(xx,yy,X(i),m,n);    
    end
    % Deep end close so lin-extrapol (option)
    if length(yy)>1 & ...
	  isnan(Y(i,j)) & ...
	  X(i)>=xx(end) & ...
	  i>1 & ...
	  any(findstr(opt,'near')) & ...
	  ((X(i)-xx(end)) < 0.25*(X(i)-X(i-1)))
      D(i,j,1)=xx(end);
      Y(i,j)=diff(yy(end-1:end))/diff(xx(end-1:end))*(X(i)-xx(end))+yy(end);
    end
%      if X(i)>=1000 & any(findstr(opt,'ext')) ...
%               & abs(diff(yy(end-1:end))) < id ...
%               & xx(end) > 900                 % ~constant variable so ..
%        Y(i,j)=yy(end);                         % neighbour extrapolation
%      elseif i>1 & any(findstr(opt,'near')) ...
%            & ((X(i)-xx(end)) / (X(i)-X(i-1)) < .15) % Close so lin-extrapol
%        Y(i,j)=diff(yy(end-1:end))/diff(xx(end-1:end))*(X(i)-xx(end))+yy(end);
%      end
%    end
  end
end

zeros(M,N); ans(find(isnan(YR)))=1; D(:,:,3)=ans; % Add layer to D

if nargout==0           % Plotted output
  fig interpwp 3; clf; 
  plot(x,y,'bo-',X,YR,'r.-',X,Y,'g.-');
  legend('Data','Reference','Interpolation',0); 
  title('Interpolation by Weighted Parabolas');
  set(gca,'xtick',X,'xgrid','on');
end

%---------------------------------------------------------------
function [FZ,FR,D]=oneF(x,y,X,m,n)% X is single
global z f Z
r=tan(pi/180*10);               % Relaxation factor for points of equal x
Z=X;                            % Update global value
%find(~isnan(x)&~isnan(y));
%x=x(ans); y=y(ans);             % Remove nans from input data

[b,a,I]=neighbours(x,X);        % Find neighbouring points
D=[b,a];

if b==a                                                 % Right on a datapoint,
  [FZ,FR]=deal(y(I));                                   % use datapoint
elseif isnan(I)|I==length(x)                            % Outside,
  [FZ,FR]=deal(nan);                                   % use NaN
elseif I==1 | I==length(x)-1                            % Inside one,
  z=x(I+[0:1]);                                       % use linear
  f=y(I+[0:1]);
  if z(2)-z(1)==0, FZ=mean(f);
  else FZ=f(1)+(Z-z(1))*(f(2)-f(1))/(z(2)-z(1)); end 
  FR=NaN;
  %z=x(1:4);
  %f=y(1:4);
  %Fp1=G(1,2,3)*f(1) + G(2,3,1)*f(2) + G(3,1,2)*f(3);% F from parabola 1*
  %Fp2=G(1,2,4)*f(1) + G(2,4,1)*f(2) + G(4,1,2)*f(4);% F from parabola 
  %FR=(F(1,2)+(abs(F(1,2)-F(2,3))^m*F(3,4)+abs(F(1,2)-F(1,3))^m*F(2,3)) / ...
  %(abs(F(1,2)-F(2,3))^m       +abs(F(1,2)-F(1,3))^m       ) )/2;
  %case length(x)-1                                   % Inside last one
  %z=flipud(x(end-3:end));    % just flip the input vectors to mirror
  %f=flipud(y(end-3:end));    % and use the same formulas as over
  %Fp1=G(1,2,3)*f(1) + G(2,3,1)*f(2) + G(3,1,2)*f(3);% F from parabola 1*
  %Fp2=G(1,2,4)*f(1) + G(2,4,1)*f(2) + G(4,1,2)*f(4);% F from parabola 
  %FR=(F(1,2)+(abs(F(1,2)-F(2,3))^m*F(3,4)+abs(F(1,2)-F(1,3))^m*F(2,3)) / ...
  %(abs(F(1,2)-F(2,3))^m       +abs(F(1,2)-F(1,3))^m       ) )/2;
else                                                    % Well inside
  z=x(I+[-1:2]);                        %  (at least two on each side)
  f=y(I+[-1:2]);                                        % use WP
  if z(1)==z(2), z(1)=z(1)-abs(f(1)-f(2))*r; end % Shift points apart
  if z(3)==z(4), z(4)=z(4)+abs(f(3)-f(4))*r; end % a little bit
  if all(~diff(diff(f)./diff(z)))     % Linear relation between all 4
    [FZ,FR]=deal(f(2)+(Z-z(2))*(f(3)-f(2))/(z(3)-z(2))); % use linear
  else
%      while z(1)==z(2)
%        z(2)=(z(1)+z(2))/2;    % average z
%        f(2)=(f(1)+f(2))/2;    % average f
%        I=I-1;                 % go back one more to find ...
%        z(1)=x(I-1); f(1)=y(I-1);      % 1st point
%      end
%      while z(3)==z(4), 
%        z(3)=(z(3)+z(4))/2;    % average z
%        f(3)=(f(3)+f(4))/2;    % average f
%        I=I+1;                 % go one more to find ...
%        z(4)=x(I+2); f(4)=y(I+2);      % 4th point
%      end
    % Direct hit?
    % Reference curve
%     if z(3)==z(4)     % Use analytic limit-value formulas
%       if     m <1,    FR=(F(2,3)+abs(F(1,2)-F(2,3))^m)/2;
%       elseif m==1,    FR=(F(2,3)+F(1,2)+abs(F(1,2)-F(2,3))^m)/2;
%       else            FR=(F(2,3)+F(1,2))/2;
%       end
%     else              % or the original 4 point formula
  FR=(F(2,3)+ ...    
      (abs(F(1,2)-F(2,3))^m*F(3,4)+abs(F(2,3)-F(3,4))^m*F(1,2)) / ...
      (abs(F(1,2)-F(2,3))^m       +abs(F(2,3)-F(3,4))^m       ) )/2;
%    end
  % Parabolas:
  Fp1=G(1,2,3)*f(1) + G(2,3,1)*f(2) + G(3,1,2)*f(3);% F from parabola 1*
  Fp2=G(2,3,4)*f(2) + G(3,4,2)*f(3) + G(4,2,3)*f(4);% F from parabola 2
  % Final value:
  FZ=(abs(FR-Fp1).^n.*Fp2 + abs(FR-Fp2).^n.*Fp1) ./ ...
     (abs(FR-Fp1).^n     + abs(FR-Fp2).^n    );
  end
end

%-------------------------------------------------------------------
function G=G(i,j,k)
global z Z % f
%zz=z; % local to this function
%if z(3)==z(4), zz(4)=z(4)+abs(f(4)-f(3))/100; end % about 10 degrees
  
G = ((Z   -z(j)).*(Z   -z(k))) ./ ...
    ((z(i)-z(j)).*(z(i)-z(k)));

%-------------------------------------------------------------------
function F=F(i,j)
global z f Z
F = (f(i).*(Z-z(j)) - f(j).*(Z-z(i))) / (z(i)-z(j));

%-------------------------------------------------------------------
function [x,y,X]=example() % example-profile from Reiniger and Ross
% Depth:
x=[0 10 29 73 97 146 195 244 294 392 478 581 686 802 1022 1140 1493 ...
   2095 2213]; 
% Temperature
y=[295 295 296 362 850 841 765 755 672 555 498 472 441 424 406 394 374 344 ...
  334]/100; 
% Salinity:
%y=33+[55 56 53 228 1419 1710 1708 1828 1820 1882 1901 1948 1937 1949 1955 ...
%      1948 1953 1954 1953]/1000;
% Interpolation-points:
X=[0:10:2300];

