function c=plotmark(pos,mark,h)
% PLOTMARK      adds marks like a), b) etc. to the left of plot
% Handy when making arrays of subplots inside a figure. Without
% marks/numbers, it will be difficult to make a good caption to such a
% figure.
%
% plotmark(pos,mark,h)
%
% pos   = optional position character,
%		't'	= top left (default)
%		'b'	= bottom left
%		'i'	= inside upper left
%		'ct'	= close to the top left
%         or vector of x and y position relative to the axes.
% mark  = string or character (including the left parenthesis if wanted). 
%         Cellstring- or character-array are accepted for multiple plot-
%         marking. Numeric input (vector only) will give ASCII
%         character(s) from 1='a)', 2='b)', ... (for upper case letters,
%         subtract 32). For numeric _marks_, use INT2STR around numeric
%         input (default = a) ,b,.. for the number of handles given)
% h     = vector of handles to axes for multiple marking of plots in one
%         command. The number of input marks must match the number of
%         handles. 
%
% c	= handles to plotmarks (text object)
%
% See also INT2STR FIGSTAMP TEXT CHAR 

%Time-stamp:<Last updated on 03/05/19 at 23:38:40 by even@gfi.uib.no>
%File:</home/janeven/matlab/evenmat/plotmark.m>

error(nargchk(0,3,nargin));
if nargin < 3 | isempty(h),	h=gca;			end
if nargin < 2 | isempty(mark),	mark=1:length(h);	end
if nargin < 1 | isempty(pos),	pos='t';		end

if isnumeric(pos)
  %pos=[pos 1];	
  ha='right';	va='top';
else
  switch pos
   case 't' ,	pos=[-.12 1.08];	ha='right';	va='middle';
   case 'b',	pos=[-.1 -0.1];	ha='right';	va='middle';
   case 'i',	pos=[0.015 1];	ha='left';	va='top';
   case 'ct',	pos=[0 1.01];	ha='left';	va='bottom';
  end
end

if ~strmatch(get(h,'type'),'axes')
  error('Input handle must be an axis-handle!');
end

if length(mark)~=length(h)
  error('Numbers of marks and axis-handles must match!');
end

mark=mark(:);

if iscell(mark)                         % handle cellstring input
  if isnumeric(mark{1}), error('Numeric cell arrays are illegal!'); 
  else char(mark);
  end
end

if isnumeric(mark)                      % transform numeric input
  mark=strcat(char(96+mark),')');       %ASCII lower-case starts 
end                                     % at 97, upper-case at 65

for i=1:length(h)
  findobj(h(i),'tag','plotmark'); if any(ans), delete(ans); end
  set(get(h(i),'parent'),'CurrentAxes',h(i));
  %
  c(i)=text(pos(1),pos(2),mark(i,:), ...
         'units','normalized','fontweight','bold', ...
         'HorizontalAlignment',ha,...
	 'VerticalAlignment',va,...
	 'tag','plotmark');
  set(c,'units','data');
end
