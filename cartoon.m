function h = cartoon(m,n,p,s)
% CARTOON	Tight kind of subplot.
%
% This is meant for plots without ticklabels, but you can set the
% spacing if you must. Mind you, this is a crude function without the
% finesse of subplot. E.g., you cannot make axes current by calling the
% same CARTOON command again. You have to use the axes handles for
% revisiting the same axes, or else CARTOON will just make a new one on
% top of the other.
% 
% h = cartoon(m,n,p,s)
% 
% m,n,p = regular SUBPLOT input
% s	= spacing (default 0.01 of figure width)
%
% Note that negative margins are also possible, if your imagination
% requires it.
% 
% See also SUBPLOT SUBPLAY MULTILABEL

error(nargchk(3,4,nargin));
if nargin<4 | isempty(s), s=0.01; end
if p>m*n, error('Frame number out of bounds!'); end
if n>1,	x=linspace(0,1,n+1); x=x(1:end-1); dx=x(2)-x(1); 
else, x=0; dx=1;  
end
if m>1, y=linspace(0,1,m+1); y=y(1:end-1); dy=y(2)-y(1); 
else, y=0; dy=1; 
end
dx=dx-s; x=x+s/2;
dy=dy-s; y=y+s/2;
row=max(0,floor((p-1)/n))+1; % from top
col=max(1,p-(row-1)*n); % from left
h=axes('position',[x(col) y(end-row+1) dx dy]);
