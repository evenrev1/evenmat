function blackfig(h)
% BLACKFIG	Switch figures to black background
% 
% blackfig(h)
% 
% h	= handle(s) to figure to operate on (default = current)
% 
% See also FIG BLACK

error(nargchk(0,1,nargin));
if nargin<1 | isempty(h),	h=gcf;		end

set(h,'color','k')

for i=1:length(h)
  ch=get(h(i),'children');
  leg=findobj(ch,'tag','legend');
  %ax=setdiff(ch,leg);
  set(ch,'color','k','xcolor','w','ycolor','w');
  ch=get(leg,'children');
  txt=findobj(ch,'type','text');
  set(txt,'color','w');
end
