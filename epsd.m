function [P,f,Pc]=epsd(x,nfft,Fs,window,overlap,dflag,p)
% EPSD          advanced PSD function
%    -automatic distribution of blocks to use the whole dataseries
%    -ability to input several timeseries at the same time as columns in a
%     matrix
%    -fixes the weight of output (the factor2 problem)
%
% [P,f,Pc] = epsd(x,nfft,Fs,window,overlap,dflag,p)
% 
% x       = vector or array with equal length timeseries as COLUMNS
% nfft    = FFT-length                  (recommended 2^n >= 256 = default)
% Fs      = sampling-frequency          (default = 1)
% window  = window type given as in PSD (default = hanning(nfft))
% overlap = number of samples overlap   (default = automatic adjustment)
% dflag   = detrending as in PSD	(default = 'linear')
% p       = set percent (p*100%) for confidence interval (default = 0.95) 
%
% P	  = PSD-estimates with frequency along first dimension (columns),
%	    and same higher dimenson sizes as input x
% f       = the frequencies of the estimates
% Pc      = confidence interval, size(P,1)-by-2-by-size(P,2). 
%           Two columns first for lower limit, second for upper limit.
%
% WHEN NO OUTPUT IS REQUESTED (RECOMMENDED TEST): 
% 1) An automatic plot is made. When only one timeseries (vector x) is
%    input, the 95% confidence interval is shown as a grey patch around
%    the spectral estimate.
% 2) Block parameters and a test for conservation of variance is
%    displayed in the command window. The integrated spectral estimate
%    should be near equal to the variance of the time series. The factor
%    two error should be fixed in this function, so any differences is
%    due to the use of windows, leakage, etc.
%
% See also PSD PWELCH

%Time-stamp:<Last updated on 06/09/14 at 11:31:25 by even@nersc.no>
%File:</home/even/matlab/evenmat/epsd.m>

error(nargchk(1,7,nargin));
xdim=isvec(x);
if xdim==2, x=x'; end	% if row vector in, transpose to column vector

% initialization
D=size(x);
M=D(1); N=prod(D(2:end));	% flip out into matrix (if array)
x=reshape(x,M,N);

% argumentcheck
if nargin < 2 | isempty(nfft)
  nfft=min([256 M]); % power of 2
%  nfft=M; % power of 2 % for no smoothing as default % agf211
end
if nargin < 3 | isempty(Fs)
  %Fs=12; % for work with monthly data
  Fs=1; % for arbitrary data
end
if nargin < 4 | isempty(window)
  window=hanning(nfft);
%  window=boxcar(nfft); % agf211
end
if nargin < 5 | isempty(overlap)
  overlap=[];
%  overlap=0;     % agf211
end
if nargin < 6 | isempty(dflag) | ~ischar(dflag)
  dflag='linear';
end
if nargin < 7 | isempty(p)
  p=0.95;
end

if strcmp(dflag,'mean'),	dtflag='constant';	% for variance
elseif strcmp(dflag,'none'),	dtflag='';	% for variance
else				dtflag=dflag;	end

blocklen=length(window);

if isempty(overlap)   % skvis inn så mange blokker som mulig
  % hvor mange blokker er det plass til med max 50% overlapp?
  if M < 1.5*blocklen
    overlap=0;K=1;M=blocklen;
  else
    K2=floor(M/blocklen*2);      % halve blokker
    K=K2-1;                  % hele blokker
    % hvor mange punkter er til overs med 50% overlapp?
    res=M-K2*blocklen/2;
    % hvordan kan man legge blokkene for å fylle hele serien?
    overlap=blocklen/2-floor(res/(K-1));
  end
else 
  % hvor mange blokker med spesifisert lengde og overlapp er der plass til?
  n=overlap;K=-1;
  while n <= M
    n=n+(blocklen-overlap);
    K=K+1;
  end
  M=n-(blocklen-overlap);
end

% beregn PSD på hver kolonne i matrisen (funker også for ren kolonnevektor)
[P(:,1),Pc(:,:,1),f]=psd(x(1:M,1),nfft,Fs,window,overlap,p,dflag);	% First get f
for i=2:N						% then loop the rest
  [P(:,i),Pc(:,:,i),f]=psd(x(1:M,i),nfft,Fs,window,overlap,p,dflag);
end

% ved complex x legges fortsatt speilbildene sammen
if any(~isreal(x))
  P=2*P(1:size(P,1)/2,:);
  Pc=2*Pc(1:size(P,1)/2,:);
  f=f(1:length(f)/2,:);
end

% psd doesn't compensate for negative freqs missing (it's quasi-one-sided):
if any(imag(x))
  P=P./Fs;
  Pc=Pc./Fs;
else
  P=P.*2/Fs;
  Pc=Pc.*2/Fs;
end

% plott og utskrift av noen viktige data dersom ingen utargumenter oppgitt
if nargout==0
  if any(dtflag), x=detrend(x,dtflag); end		% for VARTEST
  varians=var(x);
  fig epsd 4; clf;				
  pars=[   'nfft=',int2str(nfft),...
	 '; overlap=',int2str(overlap),...
	 '; blocks=',int2str(K),...
	 '; M=',int2str(M)];
  disp(pars)
  slab='Spectral estimate [variance/frequency]';
  if N<10
    disp([ 'Variance            : ',num2str(varians)])	  %  VARTEST
    disp([ 'Integrated spectrum : ',num2str(sum(P)/nfft*Fs)])% (bør være like)  
    if N==1
      h=errorpatch(f,P,P-Pc(:,1),Pc(:,2)-P); % the way errorpatch works 
      % is not like Pc is defined Pc(:,1) to Pc(:,2) indicates the interval.
      set(gca,'ylim',[0 2*max(P)]); %compensate for the huge upper limit
      set(h(1),'marker','.');
    else      
      plot(f,P);
    end
    ylabel(slab)
  else
    contourf(repmat(f,1,N),repmat([1:N],size(f,1),1),P); 
    ecolorbar(P,'r',slab);
    ylabel('Second dimension');
  end
  title(pars);
  xlabel('Frequency')
end

MP=size(P,1);
P=reshape(P,[MP D(2:end)]);

if xdim==2, f=f'; P=P'; end	% row vector input => row output




