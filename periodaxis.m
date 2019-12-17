function periodaxis(label,ax,periods)
% PERIODAXIS    changes a frequency axis to period axis. 
% Adds label, so just use this where you would call the label-command. 
%
% periodaxis(label,ax,periods)
%
% label       = string with period-axis label
% ax          = optional string giving which axis is the frequency-axis 
%               ('X' (default),'Y' or 'Z')
% periods     = optional vector forcing periods for ticks
%
% See also DATEAXIS

%Time-stamp:<Last updated on xxx at yyyy by even@nersc.no>
%File:</Users/a21627/matlab/evenmat/periodaxis.m>

error(nargchk(0,3,nargin));
%if nargin < 3 | isempty(scalefactor)
%  scalefactor=1;
%end
if nargin < 2 | isempty(ax)
  ax='X';
end
if nargin < 1 | isempty(label)
  label='period';
end

% find the frequencies with labels on originally
eval(['frequencies=get(gca,''',ax,'Tick'');'])

if nargin<3 | isempty(periods)
  % find the nearest whole number or 1 decimal periods  
  periods=[ ...
      round(1./frequencies(find(frequencies > 0 & frequencies <= 1))) ...
      round(10./frequencies(find(frequencies > 1 & frequencies <= 10)))/10];
      % this grouping of tick-frequencies can be expanded if desired
  % take away the rounded periods that are equal
  periods=[periods(find(diff(periods)~=0)) periods(length(periods))];
  % assign the new tickmarks and -labels 
  periods=[max(periods)*2 periods]; % two extra
end

frequencies=sort(1./periods);

eval(['set(gca,''',ax,'Tick'',frequencies,''',ax,'TickLabel'',periods);'])

eval([lower(ax),'label(''',label,''')'])




