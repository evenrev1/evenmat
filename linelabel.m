function ht = linelabel(x,y,str,whatend)
% LINELABEL	Plot text at end of line 
% 
% ht = linelabel(x,y)
%  
% h	= handle to line
% str	= string to print
% whatend   = what end ?
%
% ht	= handle to text object 
%
% LINELABEL also aligns the text properly to the line end according
% to the lines orientation in x/y-space,
%
% See also SECARR ECURVE

%Time-stamp:<Last updated on 05/11/07 at 16:30:28 by even@nersc.no>
%File:</home/even/matlab/evenmat/linelabel.m>

% [ top | cap | {middle} | baseline | bottom ]

error(nargchk(3,4,nargin));
if nargin<4 | isempty(whatend),	whatend='end'; end 

%x=get(h,'xdata'); y=get(h,'ydata'); 

if findstr(whatend,'end'),	x=x(end-1:end); y=y(end-1:end);
else				x=x([2 1]); y=y([2 1]);
end

ht=text(x(2),y(2),str);

angle(diff(complex(x,y)));
if     ans<-pi*11/12,	ha='right';  va='middle';
elseif ans<-pi* 4/6,	ha='right';  va='top';
elseif ans<-pi* 2/6,	ha='center'; va='top';
elseif ans<-pi*1/12,	ha='left';   va='top';
elseif ans<pi* 1/12,	ha='left';   va='middle';
elseif ans<pi* 2/6,	ha='left';   va='bottom';
elseif ans<pi* 4/6,	ha='center'; va='bottom';
elseif ans<pi* 11/12,	ha='right';  va='bottom';
end

set(ht,'HorizontalAlignment',ha,'VerticalAlignment',va);
