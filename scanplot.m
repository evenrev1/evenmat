function scanplot(a,key)
% SCANPLOT      keypress zoom and scroll in a plot
%
% scanplot(a,key)
%
% a     = single handle to axis to operate on (default = current)
% key   = optional control character input, intended for in-function or
%         in-script use.  
%
% Simply type "scanplot" to initiate on current axis. A menu of available
% operations and their corresponding keys will pop up in the current
% figure. Although the menu is fully operational, SCANPLOT is designed for
% keypress functionality. Using the num-pad should make this quite easy
% (remember the num-lock).
%
% Scrolling is done in steps equal to the relevant axis' tickmark
% separation. Zooming is done in steps of one 5th of the axis' range. The
% "Full frame" operation sets both axis-limits to the data-limits of the
% axis' children.
%
% WARNING: For some reason matlab erases the figures' 'KeyPressFcn' when
% plots are added (at least with LINE), and thus deactivates
% SCANPLOT. The fix for this is not to invoke SCANPLOT again, but to
% reset with set(gcf,'KeyPressFcn','scanplot');
%
% See also ZOOM VIEW

error(nargchk(0,2,nargin));
if nargin<1|isempty(a),         a=gca;          end

fh=get(a(1),'parent'); 
sh=findobj('parent',a,'tag','stripes'); % Any STRIPES on this axis?
if nargin<2|isempty(key),       key=get(fh,'CurrentCharacter'); end

if ~any(strcmp('scanplot',get(get(fh,'children'),'tag')))
%if ~strcmp('scanplot',get(fh,'KeyPressFcn'))   % If first call
  m  =uimenu(fh,'Label','Scanplot',...
             'tag','scanplot');         % make menu
  m1 =uimenu(m,'label',sprintf('%s \t %s','Scroll Up','8'),...
             'Callback','scanplot([],''8'')');
  m2 =uimenu(m,'label',sprintf('%s \t %s','Scroll Down','2'),...       
             'Callback','scanplot([],''2'')');
  m3 =uimenu(m,'label',sprintf('%s \t %s','Scroll Left','4'),...       
             'Callback','scanplot([],''4'')');
  m4 =uimenu(m,'label',sprintf('%s \t %s','Scroll Right','6'),...       
             'Callback','scanplot([],''6'')');
  m5 =uimenu(m,'label',sprintf('%s \t %s','Page Up','9'),...       
             'Callback','scanplot([],''9'')');
  m6 =uimenu(m,'label',sprintf('%s \t %s','Page Down','3'),...       
             'Callback','scanplot([],''3'')');
  m7 =uimenu(m,'label',sprintf('%s \t %s','Page Left','7'),...       
             'Callback','scanplot([],''7'')');
  m8 =uimenu(m,'label',sprintf('%s \t %s','Page Right','1'),...       
             'Callback','scanplot([],''1'')');
  m9 =uimenu(m,'label',sprintf('%s \t %s','Zoom in x','+'),...       
             'Callback','scanplot([],''+'')');
  m10=uimenu(m,'label',sprintf('%s \t %s','Zoom out x','-'),...       
             'Callback','scanplot([],''-'')');
  m11=uimenu(m,'label',sprintf('%s \t %s','Zoom in y','*'),...       
             'Callback','scanplot([],''*'')');
  m12=uimenu(m,'label',sprintf('%s \t %s','Zoom out y','/'),...       
             'Callback','scanplot([],''/'')');
  m13=uimenu(m,'label',sprintf('%s \t %s','Full data-range','5'),...       
             'Callback','scanplot([],''5'')');
  m14=uimenu(m,'label',sprintf('%s \t %s','Zoom color-limits','c'),...       
             'Callback','scanplot([],''c'')');
  set(fh,'KeyPressFcn','scanplot');             % set keypressfunction
  if nargin<2, return; end                      % exit if key not input
end

xlim=get(a,'xlim');                     ylim=get(a,'ylim');     
xS=0.9*abs(diff(xlim));                 yS=0.9*abs(diff(ylim));
xs=min(abs(diff(get(a,'xtick'))));      ys=min(abs(diff(get(a,'ytick'))));

switch key
 case '8',      ylim=ylim+ys;           % up
 case '2',      ylim=ylim-ys;           % down
 case '4',      xlim=xlim-xs;           % left
 case '6',      xlim=xlim+xs;           % right
 case '9',      ylim=ylim+yS;           % PgUp
 case '3',      ylim=ylim-yS;           % PgDn
 case '7',      xlim=xlim-xS;           % Home
 case '1',      xlim=xlim+xS;           % End
 case '+',      xlim=xlim+[xS,-xS]/10;  % zoom in x / shrink x-axis
 case '-',      xlim=xlim+[-xS,xS]/10;  % zoom out x / enlarge x-axis
 case '*',      ylim=ylim+[yS,-yS]/10;  % zoom in y / shrink y-axis
 case '/',      ylim=ylim+[-yS,yS]/10;  % zoom out y / enlarge y-axis
 case '5',      tightaxis; return
 case 'c',	colorzoom;		% zoom caxis to data inside axis
end

set(a,'xlim',xlim);             set(a,'ylim',ylim);     

if ~isempty(sh), stripes update; end                         % update stripes 

if any(findstr(get(a,'tag'),'dateaxis'))		% update datestr
  get(a,'userdata');  dateaxis(ans.dateform,ans.axis); 
end 


