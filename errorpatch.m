function h=errorpatch(x,y,l,u,pc,lc)
% ERRORPATCH	error-interval using a patch
%
% h = errorpatch(x,y,l,u,pc,lc)
%
% x	= vector of x-positions
% y	= vector of y-values
% l,u	= vectors (or single values) of the errors below and above the
%         y-values, respectively. The u can be omitted when the two are
%         equal. The error interval for the patch will be from y(i)-l(i)
%         to y(i)+u(i).  
% pc	= colour spec for the patch (default = grey, [.8 .8 .8] )
% lc	= colour spec for the line  (default = black, 'k' )
%
% h	= vector of handles to line (first element) and patch objects.
%
% A line for y is plotted and the error-interval is drawn as a shaded region
% around this line (instead of errorbars like in ERRORBAR). NaNs in y will
% (as in PLOT) result in gaps in the y-line and the error-patch. Where the
% error vectors alone have NaNs (ie. no error estimate available), there
% will be gaps in the patch but not in the line.
%
% See also ERRORBAR PATCH PLOT

error(nargchk(3,6,nargin));
if nargin<6 | isempty(lc),	lc='k';		end
if nargin<5 | isempty(pc),	pc=[.6 .6 .6];	end
if nargin<4 | isempty(u),	u=l;		end

[M,N]=size(y);
if issingle(u),			u=repmat(u,M,N);	end
if issingle(l),			l=repmat(l,M,N);	end

x=x(:)'; y=y(:)'; l=l(:)'; u=u(:)';		% row vectors

u=y+uplus(u);	l=y-uplus(l);			% build upper and lower limit

ly=length(y);					% Find places where 
nn=[find(isnan(y)|isnan(l)|isnan(u)) ly+1];	% y-vector is separated
nn=[0 nn(find(diff(nn)>1)) ly];			% into segments 
N=length(nn);					% by NaNs

for j=2:N					% LOOP THROUGH SEGMENTS
  [(nn(j-1)+1):nn(j)];				% indices for this segment
  ans(find(all(~isnan([y(ans);l(ans);u(ans)]))));%strip away NaNs
  if ~isempty(ans)
    xp = x([fliplr(ans)    ans    ans(end)]);	% build x-loop
    yp = [u(fliplr(ans)) l(ans) u(ans(end))];	% build y-loop
    h(j)=patch(['xdata'],xp,...
	       ['ydata'],yp,...
	       'clipping','on',...
	       'facecolor',pc,...
	       'edgecolor',pc,...
	       'tag','errorpatch');
  end
end

h(1)=line(x,y,'color',lc);

set(gca,'layer','top');

% xp=xp(:,2:end);			yp=yp(:,2:end);

% xp=[flipud(xp);xp];
% yp=[flipud(yp+uplus(u));yp-uplus(l)];

%~isnan(yp);
%xp=xp(ans); yp=yp(ans);

% THE PATCHING:
