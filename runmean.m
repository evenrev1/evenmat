function [tt,yy,n]=runmean(t,y,w,tg)
% RUNMEAN       running mean
% over 'y', with square window of width 'w' in time units. Runmean is
% primitive but robust. It handles unevenly spaced data, since it searches
% out all values inside the time-span of the running time-window.   
% BEWARE: this causes the basis (N) of each mean value to vary, and number
% of datapoints used from each side of the midpoint can be different. 
%
% [tt,yy,n] = runmean(t,y,w,tg)
%
% t    = vector of time values
% y    = vector of values to be filtered. If matrix, runmean will operate
%        along columns.
% w    = the width of the running-mean-window (in time units)
% tg   = "timegrid", a vector of chosen timepoints to slide the running
%        mean over. If omitted RUNMEAN will use t.
%
% tt   = the time-vector of the filtered series (same as input, but the ends
%        are severed half a window-width) 
% yy   = the filtered data
% n    = number of samples in each bin
% 
% No output argument results in a plot of the original- and the filtered
% vector together.
%
% See also GLATT TWINE

error(nargchk(3,4,nargin));			% check input number

tdim=isvec(t);
ydim=isvec(y);
if	tdim==2,		t=t';	end	% ensure column vector in
if	ydim==2,		y=y';	end	% ensure column vector in
if	nargin<4|isempty(tg),	tg=t;
elseif	isvec(tg)==2,	tg=tg';	end

%w=floor(w/2);
%w=ceil((w-1)/2)
w=w/2;

M=length(tg);
N=size(y,2);
for i=1:M                               % the running mean
%  find(tg(i)-w<=t & t<=tg(i)+w);
  left=find(tg(i)-w<=t & t<tg(i));
  right=find(tg(i)<=t & t<=tg(i)+w);
  [left(:);right(:)];
  n(i)=length(ans);
%  if all(isnan(y(left,:)))|all(isnan(y(right,:)))
%    yy(i,:)=nans(1,N);
%  else
  if n(i)>1
    yy(i,:)=nanmean(y(ans,:));
    %yy(i,:)=mean(y(ans,:)); % normal nan-sensitive mean takes care
                            % gaps and local end-cutting.
  elseif n(i)==1
    yy(i,:)=y(ans,:);
  else
    yy(i,:)=nans(1,N);
  end
end
n=n(:);

find(t(1)+w<=tg &  tg<=t(end)-w);       % cut off the ends
tt=tg(ans,:);
yy=yy(ans,:);
n=n(ans);

if tdim==2,		tt=tt'; end	% ensure column vector out
if ydim==2,		yy=yy'; end	% ensure column vector out

% a plot
if nargout==0
  fig runmean 3;clf;%'empirical year',
  plot(t,y,'k-o',tt,yy,'r-');
  %plot(t,y,'.',tt,yy,'r-','linewidth',2);
  legend('data input','filtered series',0);
  grid on; 
  try, scanplot; catch, zoom xon; end
  title([ 'boxwidth = ',num2str(2*w)]);
%tallibing(tt,yy,n,[],'k')
  %  legend('input series','filtered series',0); 
end
