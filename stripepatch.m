function hs = stripepatch(h,lines,dir,res)
% STRIPEPATCH	STRIPEPATCH	Striped patch (replacement)
% Draws diagonal lines on already made patch areas. One practical
% advantage of this is that you can make transparent patches without
% OpenGL. 
% 
% hs = stripepatch(h,lines,dir,res)
% 
% h	= vector of handles of patches to put lines on.
% lines	= number of lines in x-axis range (default=50)
% dir	= direction of diagonal lines 
%	  'down' : downwards from left to right (default)
%         'up'   : upwards from left to right
% res	= resolution of patch edge tracing, in fractions of distance
%         between lines (default=2 ; half the line distance)
% hs	= vector of handles to the line objects (one per patch, as h)
%
% You can SET the appearance (e.g. color, linewidth, linestyle,
% marker) using the line object handles in hs.
% Remember to delete original patch if desired, _after_ making
% stripes.
%
% See also PATCH PLOT INSIDE

error(nargchk(1,4,nargin));
if nargin<4 | isempty(res),	res=2;		end
if nargin<3 | isempty(dir),	dir='down';	end
if nargin<2 | isempty(lines),	lines=50;	end

fr=res*lines;

% Build grid that is slightly larger than map, to accomodate for nans
% outside patches on the border:
xl=xlim; dx=diff(xl)/fr; x=xl(1)-2*dx:dx:xl(2)+2*dx;
yl=ylim; dy=diff(yl)/fr; y=yl(1)-2*dy:dy:yl(2)+2*dy;
[XX,YY]=meshgrid(x,y);

res=round(res); % resolution is in whole number increments

if strcmp(dir,'down'), 
  XX=flipud(XX); YY=flipud(YY); 
end

O=length(XX); X=[]; Y=[];
% Build the diagonals first 
% (to reduce number of datapoints into INSIDE, when res>1)
for k=-O:res:O
  X=[X;diag(XX,k)]; Y=[Y;diag(YY,k)];  
end
  
M=length(h);   
for i=1:M		% loop patches
  XX=X; YY=Y;
  xv=get(h(i),'xdata'); yv=get(h(i),'ydata');
  %  whos X Y xv yv ;  plot(xv,yv);
  % Speed up by a factor of 2.6:
  % Added dx and dy to make sure there are nans outside patch
  % (nans at end of diagonals to avoid connecting lines)
  min(xv)-dx<=XX&XX<=max(xv)+dx & min(yv)-dy<=YY&YY<=max(yv)+dy; 
  XX=XX(ans); YY=YY(ans);
  ind=inside(XX,YY,xv,yv);
  XX(~ind)=nan; YY(~ind)=nan;
  hs(i)=line(XX,YY);
end
% Advantage of separate patch line-plots are that properties can
% easily be set to differ, and hs matches h.

set(hs,'color','k');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return

M=length(h);   O=length(XX);
hs=[];
for i=1:length(h)	% loop patches
  X=XX;Y=YY;
  xv=get(h(i),'xdata'); yv=get(h(i),'ydata');
  ind=inside(X,Y,xv,yv);
  if any(ind)
    X(~ind)=nan; Y(~ind)=nan;
    for k=-O:2:O		% loop lines
      hh=plot(diag(X,k),diag(Y,k),'k');
      hs=[hs;hh];
    end
  end
end

