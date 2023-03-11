function [r,sig,k,R,K] = elagcorr(x,y,maxlag,alpha)
% ELAGCORR	Lagged correlation with proper significance curves 
% taking into consideration both autocorrelation and decrease in
% degrees of freedom from the lagging.  
%
% [r,sig,k,R,K] = elagcorr(x,y,maxlag,alpha)
% 
% x	 = vector of primary time series.
% y	 = vector or array of secondary time series as columns 
%	   (time = 1st dimension). 
%	   Both series must be simultaneous, i.e., start at same time
%	   and have same sampling frequency.
% maxlag = maximum lag allowed, integer (default=half of time series).
% alpha  = significance level (default=0.05), used in two-sided test.
%
% r	 = vector of correlation coefficients at each lag, by CORRCOEF.
% sig	 = vector of significance levels at each lag, by ECHELTON.
% k	 = vector of nondimensional lag.
% R	 = correlation coefficients of significant peaks.
% K	 = lags of the significant peaks.
% 
% Positive lag means the primary time series lags the secondary
% timeseries. Results are plotted if no output arguments are given.
%
% Quite often one can see lagged correlations being made and plotted
% with a smooth convex curve or even flat line indicating the
% significant level. A flat line means the authors have only checked the
% full time series, while a smooth convex curve indicates that at least
% the loss of degrees of freedom by lagging has been accounted for. They
% may have taken into account possible autocorrelations within the
% series involved, but autocorrelation may also change with lagging. As
% a brute force method ECLAGCORR considers autocorrelation by applying
% Chelton's significance test separately to each and every lagged pair
% of series being correlated.
%
% Example:
%	load noisysignals s1 s2;  % load sensor signals
%	elagcorr(s1,s2,2260);     % extreme lag to see full effect
%
% Notes:
%	It cuts the longer series down to size of the shorter, and
%	hence may not take advantage of all data that could be used
%	for lagging.
%
% See also CORRCOEF ECHELTON XCORR

error(nargchk(2,4,nargin));
if nargin<4 | isempty(alpha),	alpha=0.05;	end
P=1-(alpha/2); % two-sided test

Dx=size(x); % Can be any orientation, but must be vector.
if prod(Dx)==max(Dx), x=x(:); Dx=size(x); Mx=Dx(1);		
else, error('x must be a single time series!'); end
			
Dy=size(y); % First dimension must be time, and array is OK, ...
if prod(Dy)==max(Dy), y=y(:); Dy=size(y); My=Dy(1); end %  and row vector is OK.
if Mx==Dy(1), 
  M=Mx;		y=y(:,:); % Array -> matrix
else
  warning('Series not of equal length! Assuming simultaneous start!');
  M=min(Mx,Dy(1));	y=y(1:M,:); x=x(1:M);
end
N=prod(Dy(2:end)); 

if nargin<3 | isempty(maxlag),	maxlag=round(0.5*M);	end % default

k=-maxlag:maxlag;	% Two-sided lag

% Successive loops through k's three 'phases': 
[r,sig]=deal(nans(length(k),N)); 
for i=k(k<0) , % i, [x(1:end+i),y(1-i:end)]'
                    corrcoef(x(1:end+i),y(1-i:end)); r(i+maxlag+1,:)=ans(1,2:end); 
  sig(i+maxlag+1,:)=echelton(x(1:end+i),y(1-i:end),alpha); 
end
for i=k(k==0), % i, [x,y]'
                    corrcoef(x,y); r(i+maxlag+1,:)=ans(1,2:end);
  sig(i+maxlag+1,:)=echelton(x,y,alpha); 
end
for i=k(k>0) , % i, [x(1+i:end),y(1:end-i)]'
                    corrcoef(x(1+i:end),y(1:end-i)); r(i+maxlag+1,:)=ans(1,2:end); 
  sig(i+maxlag+1,:)=echelton(x(1+i:end),y(1:end-i),alpha); 
end

k=k';	% for consistent output

% Find all the significant correlations:
j=find(abs(r)>sig);		% Indices of significant corrs
g=groups(diff(j));		% The groups of significant corrs
for i=1:max(g)			% Loop each group
  j(g==i);			% Indices of group
  if sign(r(ans))<0
    [R(i),kk]=min(r(ans));	% Find min in negative group
  else
    [R(i),kk]=max(r(ans));	% Find max in positive group
  end
  k(ans);			% Lags for group
  K(i)=ans(kk);			% Lag of min/max of group
end

if nargout==0                                   % ... plot
  findobj(0,'name','elagcorr');
  if isempty(ans), figure; set(gcf,'name','elagcorr'); clf;
  else,		   set(0,'CurrentFigure',ans); clf; end
  if N < 2
    h=plot(k,r,k,sig,k,-sig);
    set(h(1),'linestyle','-','color','r');
    set(h(2:3),'linestyle','-','color','b');
    H=line(K,R,'marker','*','color','g','linestyle','none'); 
    xlabel('k'); ylabel r; grid; title('Lagged correlation');
    legend([h(1),h(2),H],'correlation',...
	   [num2str(P*100,'%5.2f'),'% significance level'],...
	   'Significant peaks')
  else
    error('Plotting of multiple time series needs development');
  end
end
