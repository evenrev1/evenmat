function black(lty)
% BLACK         presets for making b/w graphs
% Sets Colororder and LinestyleOrder of current figure with run through of
% the different linestyles instead of colors.   
%
% black(lty)
%
% lty  = optional string of linestyles separated by | (i.e.  '-|--|:|-.' )
%
% See also PLOT 
%      and Helpdesk->HandleGraphicsObjectProperties->Axes->LineStyleOrder

%Time-stamp:<Last updated on 02/11/21 at 08:58:45 by even@gfi.uib.no>
%File:<d:/home/matlab/black.m>

error(nargchk(0,1,nargin));
if nargin < 1 | isempty(lty) | ~ischar(lty)
  lty='-|--|-.|:|:.|:o|:x|:+|:*|:s';   % set default LineStyleOrder
end 
set(gcf,'DefaultAxesLineStyleOrder',lty, ...
	'DefaultAxesColorOrder',[0 0 0]);
addtag('black',gcf);

% Avoid setting nextplot to add, since this makes MATLAB remember all
% previous lines regardless of new plots in figure window (???)
%set(gca,'nextplot','add','colororder',[0 0 0],'linestyleorder','-|--|:|-.')

