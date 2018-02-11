function h=erock(x,y,color,side)
% EROCK         fills in the area under a line. 
% Handy for plotting of bottom profiles, hence the name (rock solid
% bottom). 
%
% h = erock(x,y,color,side)
%
% x,y   = the vectors of the line (e.g. bottom depths)
% color = optional color (default is gray)
% side  = fill 'o'ver or 'u'nder line (in case AXIS IJ) 
%
% See also FILL PLOT GRAPH3D TBASESEC

%Time-stamp:<Last updated on 09/02/17 at 17:43:40 by even@nersc.no>
%File:</Users/even/matlab/evenmat/erock.m>

error(nargchk(2,4,nargin));
if nargin<4 | isempty(side),	side='u';		end
if nargin<3 | isempty(color),	color=[.8 .8 .8];	end

x=reshape(x,1,length(x));
y=reshape(y,1,length(y));
hold on;
%plot(x,y);

dl=mima(y); axis;
if side=='o',	yl=max([dl(2) ans(4)]);
else		yl=min([dl(1) ans(3)]);
end

h=fill([x(1) x x(end)],[yl y yl],color); 

hold off;


