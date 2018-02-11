function [cs,h]=m_bwcontour(lon,lat,data,clevels,zero,nw,zw,pw,nl,zl,pl)
% M_BWCONTOUR	m_map contour plotting in black/white
%
% [cs,h] = m_bwcontour(lon,lat,data,clevels,zero,nw,zw,pw,nl,zl,pl)
%
% lon,lat,data	= coordinates and data just like for M_CONTOUR.
% clevels	= vector specifying contourlevels (see CONTOUR)
%		  (default = no specification)
% zero		= The "zero" level, separating the highs and lows.
%		  For instance zero or the mean value of the data.
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
% See also M_CONTOUR CONTOUR CLABEL

%Time-stamp:<Last updated on 05/11/08 at 22:08:33 by even@nersc.no>
%File:</home/even/matlab/evenmat/m_bwcontour.m>

error(nargchk(3,11,nargin));

if nargin<11|isempty(pl),	pl='-';		end
if nargin<10|isempty(zl),	zl='-';      end %what about
                                                  %'none'?! % '.-'
if nargin<9|isempty(nl),	nl='--';	end
if nargin<8|isempty(pw),	pw=1;		end
if nargin<7|isempty(zw),	zw=1;		end
if nargin<6|isempty(nw),	nw=1;		end
if nargin<5|isempty(zero),	zero=0;		end
if nargin<4|isempty(clevels),	clevels=[];	end

hold on
if isempty(clevels)
  [cn,hn]=m_contour(lon,lat,data,nl);
  [cz,hz]=m_contour(lon,lat,data,zl);
  [cp,hp]=m_contour(lon,lat,data,pl);
else
  [cn,hn]=m_contour(lon,lat,data,clevels,nl);
  [cz,hz]=m_contour(lon,lat,data,clevels,zl);
  [cp,hp]=m_contour(lon,lat,data,clevels,pl);
end
hold off

l=get(hp,'Userdata'); l=cat(1,l{:});

in=find(l<zero);	%hn=h(in)
iz=find(l==zero);	%hz=h(iz)
ip=find(l>zero);	%hp=h(ip)

if ~isempty(in), delete(hz(in)); delete(hp(in)); end % Delete negs
if ~isempty(iz), delete(hn(iz)); delete(hp(iz)); end % Delete zeros
if ~isempty(ip), delete(hn(ip)); delete(hz(ip)); end % Delete pos-es

hn=hn(in); hz=hz(iz); hp=hp(ip);

h=[hn;hz;hp]; % output handles
cs=cn; % output contourline coordinates just from one of the initial plots 

set(hn,'linewidth',nw);
set(hz,'linewidth',zw); %,'linestyle',zl);
set(hp,'linewidth',pw);
% set(hn,'linestyle',nl,'linewidth',nw);
% set(hz,'linestyle',zl,'linewidth',zw);
% set(hp,'linestyle',pl,'linewidth',pw);

set(h,'color','k');

