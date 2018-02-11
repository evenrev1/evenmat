function figmatch(pos,xlim,ylim,orient,xtick,ytick,a)
% FIGMATCH	Resize axes to match a printed figure
%
% figmatch(pos,xlim,ylim,orient,xtick,ytick,a)
% 
% pos		= position of axes on paper (cm) [left bottom width height] 
%		  where left and bottom define the distance from the
%		  lower-left corner of the paper 
% xlim,ylim	= range of axes in data units [minimum maximum]
% orient	= paperorientation string: 'l'andscape or 'p'ortrait
% x-,y-tick	= vectors of tickmarks to be used in figure (optional)
% a		= handle to axes to operate on (default = current axes)
%
% You have a plot of Your own results, and want to compare with published
% figures or other printed matter. FIGMATCH give you a simple means of
% scaling Your graph to match the printed figure. Then all You have to do is
% to print Your plot onto a transparency and compare.
%
% See also FIGSTAMP FIGFILE FIG PRINT
%	   Helpdesk -> Handle Graphics Objects -> Axes

%Time-stamp:<Last updated on 02/10/21 at 13:42:45 by even@gfi.uib.no>
%File:<d:/home/matlab/figmatch.m>

error(nargchk(1,7,nargin));
if nargin<7 | isempty(a),	a=gca; end
if nargin>5 & ~isempty(ytick),set(a,'ytick',ytick); end
if nargin>4 & ~isempty(xtick),set(a,'xtick',xtick); end
if nargin<4 | isempty(orient),	orient='p'; end
if nargin<3 | isempty(ylim),	ylim=get(a,'ylim'); end
if nargin<2 | isempty(xlim),	xlim=get(a,'xlim'); end

set(a,'units','centimeters');		% Units
set(a,'position',pos,...		% First set Position on screen
      'xlim',xlim,...	
      'ylim',ylim);	

if	findstr(orient,'l'),	set(gcf,'paperorientation','landscape');
elseif	findstr(orient,'p'),	set(gcf,'paperorientation','portrait');
else				warning('No paperorientation specified.');
end

get(gcf,'paperposition');		% Afterwards set origo to corner
set(gcf,'paperposition',[0 0 ans(3:4)+ans(1:2)]); %		of paper



