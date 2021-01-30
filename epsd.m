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
% See also PSD PWELCH PERIODOGRAM

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

if isempty(overlap)   % skvis inn s� mange blokker som mulig
  % hvor mange blokker er det plass til med max 50% overlapp?
  if M < 1.5*blocklen
    overlap=0;K=1;M=blocklen;
  else
    K2=floor(M/blocklen*2);      % halve blokker
    K=K2-1;                  % hele blokker
    % hvor mange punkter er til overs med 50% overlapp?
    res=M-K2*blocklen/2;
    % hvordan kan man legge blokkene for � fylle hele serien?
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

%try  % Bruk PWELCH p� nyere versjoner
    %[P(:,1),Pc(:,:,1),f]=pwelch(x(1:M,1),nfft,Fs,window,overlap,p);disp('PWELCH') 
%    [P(:,1),f,Pc(:,:,1)]=periodogram(x(1:M,1),window,nfft,Fs,'onesided','ConfidenceLevel',p); disp('Using PERIODOGRAM.');
%catch
%  % beregn PSD p� hver kolonne i matrisen (funker ogs� for ren kolonnevektor)
  [P(:,1),Pc(:,:,1),f]=psd(x(1:M,1),nfft,Fs,window,overlap,p,dflag);  disp('Using PSD.');
  for i=2:N						% then loop the rest
    [P(:,i),Pc(:,:,i),f]=psd(x(1:M,i),nfft,Fs,window,overlap,p,dflag);
  end
%end

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
    disp([ 'Integrated spectrum : ',num2str(sum(P)/nfft*Fs)])% (b�r v�re like)  
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


function [Pxx, Pxxc, f] = psd(varargin)
%PSD Power Spectral Density estimate.
%   Pxx = PSD(X,NFFT,Fs,WINDOW) estimates the Power Spectral Density of 
%   a discrete-time signal vector X using Welch's averaged, modified
%   periodogram method.  
%   
%   X is divided into overlapping sections, each of which is detrended 
%   (according to the detrending flag, if specified), then windowed by 
%   the WINDOW parameter, then zero-padded to length NFFT.  The magnitude 
%   squared of the length NFFT DFTs of the sections are averaged to form
%   Pxx.  Pxx is length NFFT/2+1 for NFFT even, (NFFT+1)/2 for NFFT odd,
%   or NFFT if the signal X is complex.  If you specify a scalar for 
%   WINDOW, a Hanning window of that length is used.  Fs is the sampling
%   frequency which doesn't affect the spectrum estimate but is used 
%   for scaling the X-axis of the plots.
%
%   [Pxx,F] = PSD(X,NFFT,Fs,WINDOW,NOVERLAP) returns a vector of frequen-
%   cies the same size as Pxx at which the PSD is estimated, and overlaps
%   the sections of X by NOVERLAP samples.
%
%   [Pxx, Pxxc, F] = PSD(X,NFFT,Fs,WINDOW,NOVERLAP,P) where P is a scalar
%   between 0 and 1, returns the P*100% confidence interval for Pxx.
%
%   PSD(X,...,DFLAG), where DFLAG can be 'linear', 'mean' or 'none', 
%   specifies a detrending mode for the prewindowed sections of X.
%   DFLAG can take the place of any parameter in the parameter list
%   (besides X) as long as it is last, e.g. PSD(X,'mean');
%   
%   PSD with no output arguments plots the PSD in the current figure window,
%   with confidence intervals if you provide the P parameter.
%
%   The default values for the parameters are NFFT = 256 (or LENGTH(X),
%   whichever is smaller), NOVERLAP = 0, WINDOW = HANNING(NFFT), Fs = 2, 
%   P = .95, and DFLAG = 'none'.  You can obtain a default parameter by 
%   leaving it off or inserting an empty matrix [], e.g. PSD(X,[],10000).
%
%   NOTE: For Welch's method implementation which scales by the sampling
%         frequency, 1/Fs, see PWELCH.
%
%   See also PWELCH, CSD, COHERE, TFE.
%   ETFE, SPA, and ARX in the System Identification Toolbox.

%   Author(s): T. Krauss, 3-26-93

%   NOTE 1: To express the result of PSD, Pxx, in units of
%           Power per Hertz multiply Pxx by 1/Fs [1].
%
%   NOTE 2: The Power Spectral Density of a continuous-time signal,
%           Pss (watts/Hz), is proportional to the Power Spectral 
%           Density of the sampled discrete-time signal, Pxx, by Ts
%           (sampling period). [2] 
%       
%               Pss(w/Ts) = Pxx(w)*Ts,    |w| < pi; where w = 2*pi*f*Ts

%   References:
%     [1] Petre Stoica and Randolph Moses, Introduction To Spectral
%         Analysis, Prentice hall, 1997, pg, 15
%     [2] A.V. Oppenheim and R.W. Schafer, Discrete-Time Signal
%         Processing, Prentice-Hall, 1989, pg. 731
%     [3] A.V. Oppenheim and R.W. Schafer, Digital Signal
%         Processing, Prentice-Hall, 1975, pg. 556

error(nargchk(1,7,nargin))
x = varargin{1};
[msg,nfft,Fs,window,noverlap,p,dflag]=psdchk(varargin(2:end),x);
error(msg)

% compute PSD
window = window(:);
n = length(x);		    % Number of data points
nwind = length(window); % length of window
if n < nwind            % zero-pad x if it has length less than the window length
    x(nwind)=0;  n=nwind;
end
% Make sure x is a column vector; do this AFTER the zero-padding 
% in case x is a scalar.
x = x(:);		

k = fix((n-noverlap)/(nwind-noverlap));	% Number of windows
                    					% (k = fix(n/nwind) for noverlap=0)
if 0
    disp(sprintf('   x        = (length %g)',length(x)))
    disp(sprintf('   y        = (length %g)',length(y)))
    disp(sprintf('   nfft     = %g',nfft))
    disp(sprintf('   Fs       = %g',Fs))
    disp(sprintf('   window   = (length %g)',length(window)))
    disp(sprintf('   noverlap = %g',noverlap))
    if ~isempty(p)
        disp(sprintf('   p        = %g',p))
    else
        disp('   p        = undefined')
    end
    disp(sprintf('   dflag    = ''%s''',dflag))
    disp('   --------')
    disp(sprintf('   k        = %g',k))
end

index = 1:nwind;
KMU = k*norm(window)^2;	% Normalizing scale factor ==> asymptotically unbiased
% KMU = k*sum(window)^2;% alt. Nrmlzng scale factor ==> peaks are about right

Spec = zeros(nfft,1); Spec2 = zeros(nfft,1);
for i=1:k
    if strcmp(dflag,'none')
        xw = window.*(x(index));
    elseif strcmp(dflag,'linear')
        xw = window.*detrend(x(index));
    else
        xw = window.*detrend(x(index),'constant');
    end
    index = index + (nwind - noverlap);
    Xx = abs(fft(xw,nfft)).^2;
    Spec = Spec + Xx;
    Spec2 = Spec2 + abs(Xx).^2;
end

% Select first half
if ~any(any(imag(x)~=0)),   % if x is not complex
    if rem(nfft,2),    % nfft odd
        select = (1:(nfft+1)/2)';
    else
        select = (1:nfft/2+1)';
    end
    Spec = Spec(select);
    Spec2 = Spec2(select);
%    Spec = 4*Spec(select);     % double the signal content - essentially
% folding over the negative frequencies onto the positive and adding.
%    Spec2 = 16*Spec2(select);
else
    select = (1:nfft)';
end
freq_vector = (select - 1)*Fs/nfft;

% find confidence interval if needed
if (nargout == 3)|((nargout == 0)&~isempty(p)),
    if isempty(p),
        p = .95;    % default
    end
    % Confidence interval from Kay, p. 76, eqn 4.16:
    % (first column is lower edge of conf int., 2nd col is upper edge)
    confid = Spec*chi2conf(p,k)/KMU;

    if noverlap > 0
        disp('Warning: confidence intervals inaccurate for NOVERLAP > 0.')
    end
end

Spec = Spec*(1/KMU);   % normalize

% set up output parameters
if (nargout == 3),
   Pxx = Spec;
   Pxxc = confid;
   f = freq_vector;
elseif (nargout == 2),
   Pxx = Spec;
   Pxxc = freq_vector;
elseif (nargout == 1),
   Pxx = Spec;
elseif (nargout == 0),
   if ~isempty(p),
       P = [Spec confid];
   else
       P = Spec;
   end
   newplot;
   plot(freq_vector,10*log10(abs(P))), grid on
   xlabel('Frequency'), ylabel('Power Spectrum Magnitude (dB)');
end

function [msg,nfft,Fs,window,noverlap,p,dflag] = psdchk(P,x,y)
%PSDCHK Helper function for PSD, CSD, COHERE, and TFE.
%   [msg,nfft,Fs,window,noverlap,p,dflag]=PSDCHK(P,x,y) takes the cell 
%   array P and uses each element as an input argument.  Assumes P has 
%   between 0 and 7 elements which are the arguments to psd, csd, cohere
%   or tfe after the x (psd) or x and y (csd, cohere, tfe) arguments.
%   y is optional; if given, it is checked to match the size of x.
%   x must be a numeric vector.
%   Outputs:
%     msg - error message, [] if no error
%     nfft - fft length
%     Fs - sampling frequency
%     window - window vector
%     noverlap - overlap of sections, in samples
%     p - confidence interval, [] if none desired
%     dflag - detrending flag, 'linear' 'mean' or 'none'

%   Author(s): T. Krauss, 10-28-93

msg = [];

if length(P) == 0 
% psd(x)
    nfft = min(length(x),256);
    window = hanning(nfft);
    noverlap = 0;
    Fs = 2;
    p = [];
    dflag = 'none';
elseif length(P) == 1
% psd(x,nfft)
% psd(x,dflag)
    if isempty(P{1}),   dflag = 'none'; nfft = min(length(x),256); 
    elseif isstr(P{1}), dflag = P{1};       nfft = min(length(x),256); 
    else              dflag = 'none'; nfft = P{1};   end
    Fs = 2;
    window = hanning(nfft);
    noverlap = 0;
    p = [];
elseif length(P) == 2
% psd(x,nfft,Fs)
% psd(x,nfft,dflag)
    if isempty(P{1}), nfft = min(length(x),256); else nfft=P{1};     end
    if isempty(P{2}),   dflag = 'none'; Fs = 2;
    elseif isstr(P{2}), dflag = P{2};       Fs = 2;
    else              dflag = 'none'; Fs = P{2}; end
    window = hanning(nfft);
    noverlap = 0;
    p = [];
elseif length(P) == 3
% psd(x,nfft,Fs,window)
% psd(x,nfft,Fs,dflag)
    if isempty(P{1}), nfft = min(length(x),256); else nfft=P{1};     end
    if isempty(P{2}), Fs = 2;     else    Fs = P{2}; end
    if isstr(P{3})
        dflag = P{3};
        window = hanning(nfft);
    else
        dflag = 'none';
        window = P{3};
        if length(window) == 1, window = hanning(window); end
        if isempty(window), window = hanning(nfft); end
    end
    noverlap = 0;
    p = [];
elseif length(P) == 4
% psd(x,nfft,Fs,window,noverlap)
% psd(x,nfft,Fs,window,dflag)
    if isempty(P{1}), nfft = min(length(x),256); else nfft=P{1};     end
    if isempty(P{2}), Fs = 2;     else    Fs = P{2}; end
    window = P{3};
    if length(window) == 1, window = hanning(window); end
    if isempty(window), window = hanning(nfft); end
    if isstr(P{4})
        dflag = P{4};
        noverlap = 0;
    else
        dflag = 'none';
        if isempty(P{4}), noverlap = 0; else noverlap = P{4}; end
    end
    p = [];
elseif length(P) == 5
% psd(x,nfft,Fs,window,noverlap,p)
% psd(x,nfft,Fs,window,noverlap,dflag)
    if isempty(P{1}), nfft = min(length(x),256); else nfft=P{1};     end
    if isempty(P{2}), Fs = 2;     else    Fs = P{2}; end
    window = P{3};
    if length(window) == 1, window = hanning(window); end
    if isempty(window), window = hanning(nfft); end
    if isempty(P{4}), noverlap = 0; else noverlap = P{4}; end
    if isstr(P{5})
        dflag = P{5};
        p = [];
    else
        dflag = 'none';
        if isempty(P{5}), p = .95;    else    p = P{5}; end
    end
elseif length(P) == 6
% psd(x,nfft,Fs,window,noverlap,p,dflag)
    if isempty(P{1}), nfft = min(length(x),256); else nfft=P{1};     end
    if isempty(P{2}), Fs = 2;     else    Fs = P{2}; end
    window = P{3};
    if length(window) == 1, window = hanning(window); end
    if isempty(window), window = hanning(nfft); end
    if isempty(P{4}), noverlap = 0; else noverlap = P{4}; end
    if isempty(P{5}), p = .95;    else    p = P{5}; end
    if isstr(P{6})
        dflag = P{6};
    else
        msg = 'DFLAG parameter must be a string.'; return
    end
end

% NOW do error checking
if (nfft<length(window)), 
    msg = 'Requires window''s length to be no greater than the FFT length.';
end
if (noverlap >= length(window)),
    msg = 'Requires NOVERLAP to be strictly less than the window length.';
end
if (nfft ~= abs(round(nfft)))|(noverlap ~= abs(round(noverlap))),
    msg = 'Requires positive integer values for NFFT and NOVERLAP.';
end
if ~isempty(p),
    if (prod(size(p))>1)|(p(1,1)>1)|(p(1,1)<0),
        msg = 'Requires confidence parameter to be a scalar between 0 and 1.';
    end
end
if min(size(x))~=1 | ~isnumeric(x) | length(size(x))>2
    msg = 'Requires vector (either row or column) input.';
end
if (nargin>2) & ( (min(size(y))~=1) | ~isnumeric(y) | length(size(y))>2 )
    msg = 'Requires vector (either row or column) input.';
end
if (nargin>2) & (length(x)~=length(y))
    msg = 'Requires X and Y be the same length.';
end

dflag = lower(dflag);
if strncmp(dflag,'none',1)
      dflag = 'none';
elseif strncmp(dflag,'linear',1)
      dflag = 'linear';
elseif strncmp(dflag,'mean',1)
      dflag = 'mean';
else
    msg = 'DFLAG must be ''linear'', ''mean'', or ''none''.';
end

