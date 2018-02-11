function [a,y]=anomaly(x,f)
% ANOMALY       constructs a series of anomalies from a timeseries array
%
% [a,y] = anomaly(x,f)
%
% x     = vector or array with columns of time series. Array with any
%	  number of dimensions can be input, as long as the first
%	  dimension (along columns) is time. All columns are treated
%	  separately.  
% f     = the number of samples in one empirical cycle
%	  (default = 12 for seasonal cycle in monthly data).
%
% a	= the anomalies in an array of same size as input x (M-by-N-by-O-...)
% y	= the "normal" period (year) in a similar array but with size 
%         (f-by-N-by-O-...)
%
% EXAMPLES: 
% Input f=1 results in output of the perturbations from the
% overall mean, ie.	    _
%			u = u + u'   <=>   [u_pert,u_mean]=ANOMALY(u,1)
% 
% Removing the empirical seasonal cycle from a timeseries x of monthly data
% can be done by
%			a = ANOMALY(x)
%
% An array of timeseries from different locations must have time running
% along the 1st dimension (columns). It might have longitude along rows and
% latitude inward in the third dimension, and maybe even vertical levels in
% the 4th dimension. In any case, ANOMALY will treat each spatial point
% separately, making it's calculations only along the time-dimension.
%
% INVERSE TRANSFORMATION: 
% After creating the anomalies (a) and the normal period (y), there is
% really no need to let the original dataset take up space. Backtracking can
% be done by input of a and y, ie.
% 
%			x = ANOMALY(a,y)
%
% No output argument results in a plot of the original data and the
% empirical cycle together, in a one-year plot.
%
% See also MEAN NANMEAN

%Time-stamp:<Last updated on 12/04/20 at 11:24:26 by even@nersc.no>
%File:</Users/even/matlab/evenmat/anomaly.m>

error(nargchk(1,2,nargin));
if nargin<2 | isempty(f),	f=12;	end
if isvec(x)==2,		x=x(:);	end

D=size(x);			% Basic size
M=D(1); D=D(2:end);		% Separate length of first dim 
                                % from the rest 
				
if issingle(f)
  Mf=floor(M/f);		% Whole number of jumps (years)
  MM=ceil(M/f);			% One more year, covers rest of data
  x2=nans([MM*f-M,D]);		% Pad with NaNs
  y=[x;x2];			%
  y=reshape(y,[f,MM,D]);	% Put years beside eachother and push the
				% other dimensions one right
  y=permute(y,[2,1,1+[2:length(D)+1]]);% Reshape array into matrix so nanmean
  %%%y=y(:,:);	% Not necessary for nanmean
  y=nanmean(y);			% can find the mean along rows
  y=reshape(y,[f,D]);		% Shape back to "original" form with 
				% N and O as 2nd and 3rd dimensions
  Y=repmat(y,[MM+1,ones(1,length(D))]);	% Stack years to fit
  Y=cutmat(Y,1:M,1);			% data-matrix for calculations
  a=x-Y;			% Anomalies = remove average
else % NOT UPDATED
  y=f;				% INVERSE:
  d=size(y);
  f=d(1); d=d(2:end);
  if d~=D, error('The length of higher dimensions must match!'); end
  Mf=floor(M/f);			%
  Y=repmat(y,[Mf+1,ones(1,length(D))]);	%
  Y=cutmat(Y,1:M,1);			%
  a=Y+x; % x=Y+a (output is x)
end

% a plot only if single time series
if nargout==0 & length(D)==1 & D(1)==1
  fig anomaly 13;clf;
  subplot 211
  b=reshape(x(1:Mf*f),[f,Mf]);
  %plot(y,'k-o',,y,'r-');
  plot(1:f,y,'ro',1:f,b,'b.'); % ,'linewidth',2
  legend('empirical year','data input',0);
  grid on; 
  %try, scanplot; catch, zoom xon; end
  title([ 'Length of year is ',num2str(f),' samples']);
  xlabel('In year sample number');
  ylabel('Input data')
  subplot 212
  b=reshape(a(1:Mf*f),[f,Mf]);
  plot(1:f,zeros(f,1),'ro',1:f,b,'b.'); % ,'linewidth',2
  legend('''Empirical year''','Anomalies',0);
  grid on; 
  %try, scanplot; catch, zoom xon; end
  title([ 'Length of year is ',num2str(f),' samples']);
  xlabel('In year sample number');
  ylabel('Anomaly')
end
