function c=autocorr(y,M,opt)
% AUTOCORR      Autocorrelation function (normalized)
%
% c = autocorr(y,M,opt)
%
% y     = timeseries, vector or array with time as 1st dimension
% M     = integer maximum lag (default = 1/4 timeseries length
%         (Jenkins & Watts, 1969)). Although this input can be used to
%         force longer lags, but then there is danger of instabilities
% opt   = Option on method for normalization of the correlation: 
%         'biased'   - scales the raw auto-covariance by 1/R.
%         'unbiased' - scales the raw auto-covariance by 1/(R-M)
%         'coeff'    - normalizes the sequence so that the auto-
%                      correlations at zero lag are identically 1.0,
%                      ie. normalization by variance, scale by 1/c_0
%                      (this is the default). 
%         'none'     - no scaling
%
% c     = vector or array of autocorrelation function(s) with lag along
%         columns 
%        
% Uses XCORR to do the calculations for each timeseries, and as far as I can
% see the results match those of the following algorithm:
%
%      c_k_raw = sum_{i=1}^{R-k} y_i y_{i+k},   k=0,...,M
%
% Here y is always demeaned first. Normalization of the result is done as
% specified above. If XCORR (SIGNAL-toolbox) is not available, the above
% algorithm will be used (which is far slower).
%
% Results are plotted if no output arguments are given.
%
%   Jenkins,G.M. and Watts,D.G., 1969. Spectral analysis and its
%   applications. Holden-Day series in time series analysis, 1, 513 pp.
%
% See also XCORR CORRCOEF COV ITS

%Time-stamp:<Last updated on 12/04/10 at 15:36:09 by even@nersc.no>
%File:</Users/even/matlab/evenmat/autocorr.m>

D=size(y); cols=prod(D(2:end));
R=D(1);
if nargin<3 | isempty(opt),     opt='coeff';    end
if nargin<2 | isempty(M),       M=floor(R/4);   end     
if isvec(y)==2,                 y=y';           end
opt=opt(1);

y=y(:,:);                               % Data array -> matrix

t=1:R;
%y=detrend(y,'constant');%%		% Demean
%y=detrend(y,'linear');%%		% Detrend
% with NaN-toolbox:
%y=detrend(t,y,0);%%		% Demean
%y=detrend(t,y,1);%%		% Detrend
y=detrend(y);%%		% Detrend (matlab's)

c=nans(M+1,cols);                       % Preallocate memory
% try
%   for j=1:cols,                         % Loop each timeseries/column
%     xcorr(y(:,j),M,opt);                % two-sided estimate
%     c(:,j)=ans(M+1:end);                % pick one side
%   end
%   clear ans
% catch                                   % In case XCORR not avail.
  if opt=='u',%'u'
    for k=0:M                                   % Loop each lag 
      nn=sum(isnan(y(1:R-k,:)));
      c(1+k,:)=nansum(y(1:R-k,:).*y(1+k:R,:))./(R-k-nn);
      %c(1+k,:)=sum(y(1:R-k,:).*y(1+k:R,:))/(R-k);
    end
  else, %'not u'
    for k=0:M                                   % Loop each lag 
      nn(1+k,:)=sum(isnan(y(1:R-k,:)));
      c(1+k,:)=nansum(y(1:R-k,:).*y(1+k:R,:));
      %c(1+k,:)=  sum(y(1:R-k,:).*y(1+k:R,:));%%       
    end
    switch opt
     case 'b', %'b'
      c=c./(R-nn);%%%                         % Biased
     case 'c', %'c'
      c=c./repmat(c(1,:),M+1,1);%%      % Normalization by c_0
    end      
  end
% end

if nargout==0                           % ... a plot
  fig autocorr 4; clf;
  if cols < 7
    plot(0:M,c); legend(strcat('x=',int2str([1:cols]')));
    ylabel c_k;  grid;  zoom xon;
  else
    contourf(0:M,1:cols,c');
    ecolorbar(c,[],'c_k'); ylabel('timeseries #');
  end
  xlabel k; title Autocorrelation;
end

% format output
c=reshape(c,[M+1 D(2:end)]);

