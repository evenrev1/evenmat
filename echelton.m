function [sig_corr,Nstar] = echelton(x,y,alpha)
% ECHELTON	Chelton's significance test
% 
% [sig_corr,Nstar] = echelton(x,y,alpha)
% 
% x	= single (column) time series
% y	= array of time series as columns (time = 1st dimension)
% alpha = significance level (default=0.05)
%
% sig_corr = significance levels for the correlations
% Nstar    = effective degrees of freedom
%
% The significance level for cross-regression you can calculate
% yourself just like you calculate the regression itself, by
% sig_reg=sig_corr.*nanstd(y)./nanstd(x);
%
% The formulae for Nstar is from Chelton (1983), and is also described
% in the book "Data Analysis, Methods in Physical Oceanography" by Emery
% and Thomson (page 260 in the edition from 2004).
%
% TESTING STAGE: In case of NaNs in data, the sum of cross-covariances
% for the Nstar denominator are calculated from the longest segment of
% contiuous data. N is still the number of actual samples (non-NaNs).
%
% The significance level is calculated by the standard Student's t-test.
% More info here:
% http://janda.org/c10/Lectures/topic06/L24-significanceR.htm Note
% that on this webpage they calculate t for a given correlation
% coefficient, while we here calculate the correlation coefficient
% (sig_corr) for a given t.
%
% Based on A. B. Sandoe and H. R. Langehaug's code for the method.
% 
% See also ETREND ITS AUTOCORR

error(nargchk(2,3,nargin));
if nargin<3 | isempty(alpha),	alpha=0.05;	end

Dx=size(x);		Dy=size(y);
Nx=Dx(1);		Ny=Dy(1); % First dimension is time
xcols=prod(Dx(2:end));	ycols=prod(Dy(2:end));
if Nx==Ny, N=Nx; else, error('Series must be of equal length!'); end
if xcols>1, error('x must be a single time series!'); end
x=x(:);			y=y(:,:);

P=1-(alpha/2); % two-sided test

XC=xcov(x,'coeff');
X=bridge(x); 
% loop columns with not all nans (i.e., land etc.):
I=~isnan(y);
[Nstar,sig_corr]=deal(nans(1,ycols));
%for j=1:ycols		% Do each column separately
for j=find(~all(~I))	% Do each non-NaN column separately
  % Calculation of effective degrees of freedom: 
  if any(isnan(x)|isnan(y(:,j)))	% There are NaNs in this column
    N=length(find(~isnan(x)&I(:,j)));
    if logical(0)	% bridge data to find denominator (dubious) 
      Y=bridge(y(:,j)); 
      ~isnan(X)&~isnan(Y); X=X(ans); Y=Y(ans);
      Nstar(j)=N/nansum(xcov(X,'coeff').*xcov(Y,'coeff')+xcov(X,Y,'coeff').*xcov(Y,X,'coeff'));
    else		% use longest continuous part to find denominator 
      in=[1;find(isnan(x));length(x)];	% indices for gaps
      [m,im]=max(diff(in));  % largest space between gaps
      i=in(im)+1:in(im+1)-1; % this 'gap' in the gaps = longest segment of data
      X=x(i); Y=y(i,j);
      Nstar(j)=N/nansum(xcov(X,'coeff').*xcov(Y,'coeff')+xcov(X,Y,'coeff').*xcov(Y,X,'coeff'));
    end
  else				% No NaNs in this column; normal formula
    Nstar(j)=N/nansum(XC.*xcov(y(:,j),'coeff')+xcov(x,y(:,j),'coeff').*xcov(y(:,j),x,'coeff'));
  end
  Nstar(j)=min(Nx-1,Nstar(j));
  % Calculation of significance level: 
  t=tinv(P,Nstar(j)-2);
  sig_corr(j)=t./((Nstar(j)-2)+(t).^2).^0.5; % significance level for cross-correlation
  %%%%sig_reg(j)=sig_corr(j)*s_y/s_x; % significance level for cross-regression
end

Nstar=reshape(Nstar,[1 Dy(2:end)]);                 % Matrix -> array
sig_corr=reshape(sig_corr,[1 Dy(2:end)]);                 % Matrix -> array
%%%%sig_reg=reshape(sig_reg,[1 Dy(2:end)]);                 % Matrix -> array
