function [tt,yy]=glatt(t,y,fc,method,pass)
% GLATT         Advanced "automized" filtering
% of series based on either input time-vector or sampling-period. Handles
% inhomogeneous sampling and NaNs in data by linear interpolation. Performs
% a zero-phase forward and reverse digital filtering with Butterworth filter
% of optimized order ("optimization routine inside"). Other filters can
% also be input.
%
% STOP! THE BUTTERWORTH ROUTINE SEEMS FAULTY!
% 
% [tt,yy] = glatt(t,y,fc,method,pass)
%
% t      = a) vector           : the timepoints of the series
%          b) single value     : the sampling period of the series
%                                                  (default = 1/12)
%          c) single imaginary : dt + t_1 * i for incorporation of the
%             correct starting time (t_1) to the output time-vector (tt)
% y      = vector of the series to be filtered, or array with simultaneous
%          series as columns (time as 1st dimension)
% fc     = cutoff frequency based on same time-unit as in t (default=0.8)
% method = exact string for the filter type, either 'butter'worth
%          (default) or name of any window-function of width input only
%          (some are listed below)  
% pass   = One of the strings 'low' (default), 'high', or 'stop' for manner
%          of filtering (alternatives to "glatt"ing/smoothing).
%
% tt     = time vector of the filtered time-series
% yy     = the filtered time-series
%
% If only one inargument is given, it is assumed to be the series y, and the
% sampling-period is assumed to be 1/12 (for filtering one year and shorter
% periods from monthly data). If only one or no outargument is given, the
% output is the smoothed series (yy).
%
% When only single t (i.e. dt) is input, the correct time can be achieved
% by adding tt to the starting time of the input series.
%
% NOTE: Works only with timeseries-data sharing the same time-vector. If t
% is matrix or array, first column will be used. In other words, each row or
% higher-dimensional field must be synoptic.
%
% NaNs at ends of timeseries are extrapolated by BRIDGE before filtering.
%
% WARNING: If the input series has any extremely small time-increments, you
% may encounter memory-problems.
%
% See also FILTFILT RUNMEAN BRIDGE
%          BUTTER BOXCAR HAMMING HANNING HANN BLACKMAN BARTLETT TRIANG

%Time-stamp:<Last updated on 10/12/29 at 16:21:40 by even@nersc.no>
%File:</Users/even/matlab/evenmat/glatt.m>

error(' STOP! THE BUTTERWORTH ROUTINE SEEMS FAULTY!');

error(nargchk(1,5,nargin));                     % check input number

if nargin<5|isempty(pass),      pass='';        end
if nargin<4|isempty(method),    method='butter';end
if nargin<3|isempty(fc), fc=0.8; end            % cutoff a bit less than 1
if nargin<2|isempty(y),  y=[];   end
if nargin<1|isempty(t),  t=1/12; end

tdim=isvec(t);
ydim=isvec(y);
                                        % SORT OUT INARGUMENTS:
if nargin>=2 & ~issingle(t)             % two inputs
  if ydim==2,           y=y';   end     % ensure column vector in
  if tdim==2,           t=t'; 
  elseif ismatrix(t),   t=t(:,1);       % Assume t is uniform array
  end                   
  diff(t); mima(ans(find(ans>0)));
  dt=ans(1);                            % Pick shortest dt 
  if diff(ans)
    uniform=0;                          % Non-homogeneous sampling,
    t1=[t(1):dt:t(end)]';               % so create new time-vector
  else
    uniform=1;
    t1=t;
  end
  D=size(y);
elseif nargin>=2 & issingle(t)          % t=single, use as dt
  if ~isreal(t)
    tstart=imag(t); t=real(t);
  else, tstart=0;
  end
  dt=t; 
  uniform=1;
  if ydim==2, y=y'; end                 % ensure column vector in
  D=size(y);
  t1=tstart+[1:D(1)]'*dt;
  t=t1;
elseif nargin==1                        % one input, dt=1/12
  dt=1/12;                                      
  uniform=1;
  y=t;
  if ydim==2, y=y'; end                 % ensure column vector in
  D=size(y);
  t1=[1:D(1)]'*dt;
  t=t1;
end

if any(isnan(y(:))) | ~uniform          % INTERPOLATE
                                        % (if nans in data,
                                        %  or non-uniform timesteps)
  disp('Non uniform time sampling or NaNs in data.');
  cols=prod(D(2:end));                  
  y=reshape(y,D(1),cols);               % Reshape into matrix
  
  non=~isnan(y);                % Matrix with clean-locations (0/1)
  ncols=any(~non);              % Row vector for which cols have nans (0/1)
  for j=find(ncols)                     % For the part with nans:
    tn=t(non(:,j)); yn=y(non(:,j),j);   % Pick clean part
    y1(:,j)=interp1q(tn,yn,t1);         % and interpolate col by col
  end
  clear tn yn
  if any(~ncols)                        % For clean columns (and t was vector)
    y1(:,~ncols)=interp1q(t,y(:,~ncols),t1); % The clean part in one go
  end                                   
  find(~all(isnan(y1),2));
  y1=y1(ans,:); t1=t1(ans,:);           % Remove all-nan times
  if any(isnan(y1(:)))                  % Extrapolate remaining 
    y1=bridge(y1);                      % nan-ends 
  end
  D1=size(y1);
  y1=reshape(y1,[D1(1) D(2:end)]);      % Shape back into array
else
  y1=y;
end
                                                % FILTER
Wn=2*fc*dt;                             % Wn=2*fc/fs (normalized cutoff)
% 1.0 is fn(yquist)=fs/2 => fc/fn = fc/(fs/2) = 2*fc/fs = 2*fc*dt
%switch method
if strcmp('butter',method)
  n=min([optibutt(Wn) floor(D(1)/3)-1]);        % Find filter parameters
  if isempty(pass), [b,a]=butter(n,Wn);                 % Create filter
  else [b,a]=butter(n,Wn,pass);
  end
else
% case {'hamming','hanning','bartlett','boxcar'}
  n=ceil(1/fc/dt);      % cutoff period in number of samples
  b=feval(method,n); a=sum(b);
end

%fig filter 4; plotyy(1:length(b),b,1:length(a),a);
yy=filtfilt(b,a,y1);                            % Filter series
% MAKE AN EFILTFILT
%yy=filter(b,a,y1);                            % Filter series
%size(yy)
%yy=filter(b,a,flipud(yy));                            % Filter series
%yy=flipud(yy);
if ~strcmp(pass,'high')
  floor((1/min(Wn))+1); core=ans:(D(1)-ans+1);  % CUT AWAY ENDS 
  tt=t1(core);                                  %  For whole length T=2/Wn
  yy=cutmat(yy,core,1);                         %  For half length use T/2
else
  tt=t1;
end
  
if nargout==0 & length(D)==2 & D(2)==1          % PLOT
  fig glatt 4;                                  % if no output and vector
  h=plot(t,y,'k-o',t1,y1,'g.',tt,yy,'r-');
  legend(...%h([0:2]*N+1),...
         'data input','interpolated series','filtered series',0);
  grid on; zoom xon;
  title([ 'Filter = ',method,...
          ', filter order/width = ',int2str(n),...
          ', cutoff freq. = ',num2str(fc)]);
  %
end

if nargout<=1                                   % OUTPUT
  tt=yy;%reshape(yy,[MM D(2:end)]);
end

switch tdim                                     % RESTORE ORIENTATION
 case 1,        tt=tt(:);                       % of vector data
 case 2,        tt=tt(:)';                      % (flip to original size)
end
switch ydim
 case 1,        yy=yy(:);
 case 2,        yy=yy(:)';
end

%----------------------------------------------------------
function n=optibutt(Wn)
%%%%% OPTIMALIZATION OF BUTTERWORTH FILTER %%%%%%%%%%%%%%%%
o.Wn = 2./[4000 2000 365 200 100 50 30 24 12 10  6  5  4];
o.n  =    [   4    5   6   7   8 10 13 14 20 23 44 60 90];

for i=1:length(Wn)
  find(o.Wn<=Wn(i)+1e-5); n(i)=o.n(max(ans));
end

if isempty(n), error('Too small input f_c/f_s-ratio !'); end


