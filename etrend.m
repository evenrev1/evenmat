function [y,yl,P,Q] = etrend(x,f,degree,crit)
% ETREND	Detrend and deseason time series simultaneaously
% by calculating and subtracting trends for each calendar month
% separately. Or simple trend if one so wish. 
%
% [y,yl,P,Q] = etrend(x,f,degree,crit)
% 
% x     = vector or array with columns of time series. Array with any
%         number of dimensions can be input, as long as the first
%         dimension (along columns) is time. The series must be
%         regularly sampled.  Gaps in time series must be represented
%         by NaNs. All columns are treated separately.
% f     = the number of samples in one empirical cycle.
%	  (default = 12 for seasonal cycle in monthly data).
%	  For detrending only, set f=1.
% degree= the degree of the polynom to fit (see polyfit). Default=1. 
%         When degree>1 this is not really detrending anymore. Values
%         1-5 are accepted.
% crit  = two element vector of criteria for data coverage. First
%         element is minimum total fraction covered, second is the
%         minimum fraction of data in each quarter of the time
%         series. (default = [0.5 0.1]). See about Q below.
%         (But c'mon, you need at least three points anyway.)
%
% y	= the deseasoned and detrended time series in an array of same size
%         as input x (M-by-N-by-O-...)
% yl	= the linear fit (for degree=1), i.e. the trend. For f>1 This
%         will be the curve including rhe empirical cycle. Individual
%         (calendar month) trends can be plotted by picking every
%         f-th value, if you like.  
% P     = the polynomial coefficients from POLYFIT in array
%         (degree+1-by-f-by-M-by-N-by-O-...). First dimension has the
%         polynomial coefficients (for degree=1, first the trend then
%         the bias), next dimension is the length of empirical cycle,
%         next are the spatial dimensions as input. Unit of P is per
%         f x sample period (i.e., per month for monthly data with f=1,
%         per year for f=12).
% Q     = data coverage as fraction of 1. A 5-by-N matrix  with
%         fractions for total number of datapoints in each time
%         series, followed by distribution of fraction in four
%         quarters of the time series. Can be used to eliminate
%         trends from bad series. 
%
% No output argument results in a plot of the original and the detrended
% series together (for single time series).
%
% See also ANOMALY DETREND POLYFIT

% MAY EXTEND THIS TO HANDLE IRREGULAR TIME SAMPLING BY INCLUDING REAL
% TIME AXIS INPUT AND OUTPUT!

error(nargchk(1,4,nargin));
if nargin<4 | isempty(crit),	crit=[0.5 0.1];	end
if nargin<3 | isempty(degree),	degree=1;	end
if nargin<2 | isempty(f),	f=12;		end
if isvec(x)==2,			x=x(:);		end

D=size(x);			% Basic size
M=D(1); D=D(2:end);		% Separate length of first dim 
                                % from the rest 
if issingle(f)
  Mf=floor(M/f);		% Whole number of years with data
  MM=ceil(M/f);			% One more year, covers rest of data
  x2=nans([MM*f-M,D]);		% Pad with NaNs
  y=[x;x2];			%
  y=reshape(y,[f,MM,D]);	% Put years beside eachother and push the
  y=permute(y,[2,1,1+[2:length(D)+1]]);	% other dimensions one right.
  y=y(:,:);	% Reshape array into matrix to detrend along columns
  %%%%%y=detrend(y); 
  % DETREND DOESN'T LIKE NaNs! BUT THIS DOES:
  t=[1:Mf]';			% length of the cut series
  T=[1:MM]';			% full series is just 1 more year
  NN=size(y,2);
  %%%%  for j=1:NN % loop columns
  % loop columns with not all nans (i.e., land etc.):
  I=~isnan(y(1:Mf,:)); % logical for non-nans in rows
  yl=nans(MM,NN); 
  P=nans(degree+1,NN);
  Q=nans(5,NN);
  for j=find(~all(~I))
    perc=sum(I(:,j))/Mf;
    histc(find(I(:,j)),linspace(1,Mf,5)); H=ans(1:end-1)/Mf;
    %skewness(H); skewness(I(:,j));
    %1:Mf; skewness(ans(I(:,j))); if isnan(ans), ans=0; end
    Q(:,j)=[perc ; H(:)];
    %plot(I(:,j)); Q(:,j)', input ! % test
    %if length(find(I(:,j)))>=3
    if Q(1,j) >= crit(1) & all(Q(2:end,j)) >= crit(2) & length(find(I(:,j)))>=3
      polyfit(t(I(:,j)),y(I(:,j),j),degree);% polyfit only on whole years (to Mf)
      P(:,j)=ans';
      switch degree
       case 1, 	yl(:,j)=P(1,j)*T+P(2,j);% but make trend for whole series (to MM)
       case 2, 	yl(:,j)=P(1,j)*T.^2+P(2,j)*T+P(3);
       case 3, 	yl(:,j)=P(1,j)*T.^3+P(2,j)*T.^2+P(3,j)*T+P(4,j);
       case 4, 	yl(:,j)=P(1,j)*T.^4+P(2,j)*T.^3+P(3,j)*T.^2+P(4,j)*T+P(5,j);
       case 5, 	yl(:,j)=P(1,j)*T.^5+P(2,j)*T.^4+P(3,j)*T.^3+P(4,j)*T.^2+P(5,j)*T+P(6,j);
      end
    end
%%%% next
%   for j=find(~all(isnan(y))) 
%     I=~isnan(y(1:Mf,j));
%     if length(find(I))>=3
%       P=polyfit(t(I),y(I,j),1);	% polyfit only on whole years (to Mf)
%       yl(:,j)=P(1)*T+P(2);	% but make trend for whole series (to MM)
%     end
%%%% Old:    
%    if length(find(I))<3
%      P=[NaN NaN];
%    else
%      P=polyfit(t(I),y(I,j),1);	% polyfit only on whole years (to Mf)
%    end
%    yl(:,j)=P(1)*T+P(2);	% but make trend for whole series (to MM)
%
%%y(:,j)=y(:,j)-yl(:,j);
  % NOTE: There may be too many missing data to make a proper trend!!
  %NOTE:Should mean be taken out first, in case of too many trailing
  %or leading gaps?
  end
  %
  if ~all(isnan(yl))&any(isnan(yl)) %if any(any(isnan(yl)))
    error('Missing data in column! (ETREND not yet programmed for that)')
    % Fill months that couldn't be polyfitted (also ends)
    find(~isnan(yl(1,:))); a=ans(1); b=ans(end); 
    yl=yl(:,[a+1:f 1:a]); 
    yl=efill(yl','v4')';			% 'v4'is smooth
    yl=yl(:,[f-a+1:f  1:f-a]);
  end
  %
  yl=reshape(yl,[MM,f,D]);		  % Reshape matrix into array
  yl=permute(yl,[2,1,1+[2:length(D)+1]]); % Switch month and year dim 
  yl=reshape(yl,[MM*f D]);		  % Shape back to "original" form  
  yl=cutmat(yl,1:M,1);			  % cut away the trailing NaNs
  %
  y=x-yl;				  % Finally detrend (subtract)
  %
  Pm=size(P,1);
  P=reshape(P,[Pm,f,D]);		  % Reshape matrix into array
  Qm=size(Q,1);
  Q=reshape(Q,[Qm,f,D]);		  % Reshape matrix into array
end

% a plot
if nargout==0 & D==1
  x=x(:,:);y=y(:,:);
  fig etrend 3;clf;
  %plot(1:M,x(:,1),'k-o',1:M,y(:,1),'r-o',1:M,yl(:,1),'g-*');
  plot(1:M,x(:,1),'k-o',1:M,yl(:,1),'g-*');
  %plot(t,y,'.',tt,yy,'r-','linewidth',2);
  %legend('data input',...
  %	 'detrended and deseasoned series',...
  %	 'The ''trendline''/sequence of mothly trends',0);
  legend('data input',...
	 'The ''trendline''/sequence of mothly trends',0);
  grid on; 
  try, scanplot; catch, zoom xon; end
  %title([ 'length = ',num2str(f)]);
%tallibing(tt,yy,n,[],'k')
  %  legend('input series','filtered series',0); 
end
