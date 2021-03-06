function tightaxis(a,ax)
% TIGHTAXIS	Shrink 2D-axis to fit data 
% The same as AXIS TIGHT, but works for plots with STRIPES or DATEAXIS.
%
%  tightaxis(a,ax)
%
% a	= handle to axis (default = current axis)
% ax    = what axis to tighten, 'x' or 'y'.
%         Optional if only one axis' limits is to be changed. 
%
% See also AXIS STRIPES DATEAXIS

error(nargchk(0,2,nargin));
if nargin<2|isempty(ax),	ax='xy';	end
if nargin<1|isempty(a),		a=gca;		end

for i=1:length(a)
  sh=findobj('parent',a(i),'tag','stripes'); % Any STRIPES on this axis?
  get(a(i),'children');	
  %if any(sh),  ans(find(ans~=sh)); end
  if ~isempty(sh),  ans(find(ans~=sh)); end
  ans(find(~strcmp(get(ans,'type'),'text')));
  if ~isempty(ans),
    xlim=mima(get(ans,'xdata'));
    ylim=mima(get(ans,'ydata'));
  else
    errordlg('No data in plot!','Tightaxis error!');
  end
  
  if findstr(ax,'x'), set(a(i),'xlim',xlim); end	% set axis limits
  if findstr(ax,'y'), set(a(i),'ylim',ylim); end
  
  %if any(sh), stripes('update',[],[],[],a); end		% update stripes 
  if ~isempty(sh), stripes('update',[],[],[],a); end		% update stripes 
  if any(findstr(get(a(i),'tag'),'dateaxis'))		% update datestr
    get(a(i),'userdata'); dateaxis(ans.dateform,ans.axis); 
  end 
end

