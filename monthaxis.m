function monthaxis(dateform,ax,h)
% MONTHAXIS     changes month number ticklabels to month names
% 
% monthaxis(dateform,ax,h)
%
% dateform    = number giving the format according to the table in DATESTR
% ax          = optional string giving which axis is the time-axis 
%               ('X' (default),'Y' or 'Z')
% h	      = handle to axes to operate on
%
% See also DATEAXIS, DATENUM, DATESTR, DATEVEC, NOW, DATE

%Time-stamp:<Last updated on 02/09/16 at 22:49:06 by even@gfi.uib.no>
%File:<d:/home/matlab/monthaxis.m>

error(nargchk(0,3,nargin));
if nargin < 1 | isempty(ax)
  ax='X';
end

for i=1:length(h)
  eval(['m=get(h(i),''',ax,'Tick'');'])	% find the days with labels on
  mstr=datestr(datenum(1,m,1),dateform);	% make the ticklabels
  eval(['set(h(i),''',ax,'TickLabel'',mstr);'])  % put on the ticklabels
end

