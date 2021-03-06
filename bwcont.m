function bwcont(h,zero,nw,zw,pw,nl,zl,pl)
% BWCONT	Conourline styling for black/white plots
%
% bwcont(h,zero,nw,zw,pw,nl,zl,pl)
%
% h		= handles to line objects as returned by CONTOUR
% zero		= The "zero" level, separating the highs and lows.
%		  (default = 0)
%
% Optional styling arguments:
%
% nw,zw,pw	= linewidths of negative, zero and positive contourlines
%		  respectively. 
% nl,zl,pl	= linestyles for negative, zero and positive contourlines
%		  respectively. 
% 
% The default styles and the function itself are motivated by the desire
% to  make better contourplots in black and white, separating the "highs"
% and "lows". Remember: "If you can't do it, do it colour." 
%
% See also CONTOUR CLABEL

if nargin<8|isempty(pl),	pl='-';		end
if nargin<7|isempty(zl),	zl='none';		end
if nargin<6|isempty(nl),	nl='--';	end
if nargin<5|isempty(pw),	pw=1;		end
if nargin<4|isempty(zw),	zw=1;		end
if nargin<3|isempty(nw),	nw=1;		end
if nargin<2|isempty(zero),	zero=0;		end

l=get(h,'Userdata');
if length(l)>1, l=cat(1,l{:}); end

hn=h(find(l<zero));
hz=h(find(l==zero));
hp=h(find(l>zero));

set(hn,'linestyle',nl,'linewidth',nw);
set(hz,'linestyle',zl,'linewidth',zw);
set(hp,'linestyle',pl,'linewidth',pw);

set(h,'edgecolor','k');

