function hp = pins(h,varargin)
% PINS          Adds "vertical" lines to plotted points
% When used on point plots, this gives an impression of pins stuck to
% the x,y-plane, and is a good help for locating points in 3D graphs.
% 
% hp = pins(h)
% 
% h     = handle to objects to draw vertical lines from
%         (default = all line or patch objects in current axes, but
%         it is recommended to specify this for complex graphs)
%
% hp    = handles to the vertical lines
%
% Input can be followed by parameter/value pairs for line objects to
% give special parameters to the vertical lines. Default color is the
% color of the points.
% 
% Can also give pins from patch objects (like from SCATTER), but only
% on patch or line types _separately_. If no line objects are present,
% PINS will look for patches and use them.
%
% If no 'color' property value is given, the pins will inherit color
% from the plotted points.
%
% See also PLOT PLOT3 GRAPH3D SCATTER3

%Time-stamp:<Last updated on 03/05/29 at 15:16:59 by even@gfi.uib.no>
%File:</home/janeven/matlab/evenmat/pins.m>

if nargin<1|isempty(h), h=findobj(gca,'type','line');
elseif ischar(h),       varargin=[h,varargin]; 
                        h=findobj(gca,'type','line');
end  
% If no line objects? Still empty h? What then? Patch from scatter? Try
% to find any patches and use them:
if isempty(h),          h=findobj(gca,'type','patch');
end
% would rather like it to require patches to be specified, but will
% try if no line objects are there

% The plotting:
x=get(h,'xdata');       y=get(h,'ydata');       z=get(h,'zdata');
x=x(:)';                y=y(:)';                z=z(:)';                
if iscell(x), 
  x=cell2mat(x);        y=cell2mat(y);          z=cell2mat(z);  
end

if isempty(z)   % 2D graph => project lines onto x axis
  x0=x;         y0=zeros(size(y));
  X=[x;x0];     Y=[y;y0];
  hp=line(X,Y);
else            % 2D graph => project lines onto x/y-plane
  x0=x;         y0=y;   z0=zeros(size(z));
  X=[x;x0];     Y=[y;y0];       Z=[z;z0];
  hp=line(X,Y,Z);
end 
%

% Find colors if not given in varargin:
if isempty(varargin)|~any(strmatch(varargin,'color'))
  try   
    c=get(h,'color');
  catch 
    c=get(h,'edgecolor');
  end
  varargin={'color' c varargin{:}};
end
% (but color could have been given as input)

% Find the color from varargin:
col=varargin{find(strcmp(varargin,'color'))+1};

% Assign same colors to the vertical lines
if iscell(col)
  %N=length(hp);
  %if length(col)~=N, error('Length of cell color assignment must be ..');end
  for j=1:length(hp)
    set(hp(j),'tag','pins','color',col{j});
  end
  if length(varargin)>2, set(hp,varargin{3:end}); end
else
  set(hp,'tag','pins',varargin{:});
end

% how to assign different colors to different pins? 
% solved for extraction from original patches (taht's good enough)
