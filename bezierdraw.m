function [h,x,y]=bezierdraw(varargin)
% BEZIERDRAW    Draw curved line by mouseclicks
% Reminiscent of bezier-line drawing in Coreldraw. Simply click in plot with
% mouse to draw your line, alternating between making nodes (button 1), and
% aligning directional constrainment (button 2):
%
% [h,x,y] = bezierdraw;
%
% Input = parameter/value pairs to specify properties of the line
%         (default is a solid, black line)
%
% h     = handle to drawn line object
% x,y   = coordinate-vectors for the line
%
% Mouse-button 1              : Create node
% Mouse-button 2 (Control-B1) : Align "ruler". Click on a point "after"
%                               the node. Create nodes and create rulers
%                               alternately. Press same button again to
%                               redo last action.
% ESC-key                     : Erase nodes backwards
% Any other key               : Quit
%
% ARROWS (requires function ARROW): If the string 'arrow' or any of the
% ARROW PROPERTIES is added to the parameter/value pair input, an arrowhead
% will be added to the line. Any parameter/value pairs for line, patch and
% ARROW can be input. Only 'width' or 'linewidth' is needed. ARROW is part
% of MATDRAW which can be obtained at
% ftp://ftp.mathworks.com/pub/contrib/v5/graphics/matdraw/ .  Alternatively,
% the x and y output from BEZIERDRAW can be used as inputs to Tore Furevik's
% MY_ARROW.
%
% M_MAP users: If you want lon/lat coordinates to save the geographical
% lines, use M_XY2LL on the output x and y.
% 
% The bezier-algorithm was kindly provided by Nicolas de Dreuille
% (Nicolas.de-Dreuille@insa-rouen.fr) with explanation on
% http://servasi.insa-rouen.fr/~ndreuill/projetananum/
%
% See also ARROW GINPUT M_MAP

%Time-stamp:<Last updated on 02/06/13 at 11:49:55 by even@gfi.uib.no>
%File:<d:/home/matlab/bezierdraw.m>

for i=1:length(varargin)                % Ensure all lower case input
  varargin{i}=lower(varargin{i});
end
%----------------------------------------------------------------------
x=find(strcmp(varargin,'xdata'))+1;
y=find(strcmp(varargin,'ydata'))+1;
if any(x)&any(y)                                
  x=varargin{x}; y=varargin{y};
  h=line('xdata',x,'ydata',y);  
else                                            % no data input means
  [h,x,y]=draw;                                 % drawing by hand
end
%----------------------------------------------------------------------
if ~any(strcmp(varargin,'color'))                       % Default styles
  varargin=[varargin,{'color'},{'k'}];end
if ~any(strcmp(varargin,'linestyle'))
  varargin=[varargin,{'linestyle'},{'-'}];end

find(strcmp(varargin,'width'))+1;                       % Lineproperties
if any(ans)     
  varargin=[varargin,{'linewidth'},varargin(ans)]; 
end
lineproperties=propertiesfor('line',varargin{:});       
if ~isempty(lineproperties)                             
  set(h(1),lineproperties{:});                          
end
                                                        % Arrow:
if any(strcmp(varargin,'arrow'))|~isempty(propertiesfor('arrow',varargin{:}))
  find(strcmp(varargin,'color'))+1;                     % Default colors
  if ~any(strcmp(varargin,'edgecolor')) 
    varargin=[varargin,{'edgecolor'},varargin(ans)]; end
  if ~any(strcmp(varargin,'facecolor'))      
    varargin=[varargin,{'facecolor'},varargin(ans)]; end
  find(strcmp(varargin,'linewidth'))+1;                 % Default length
  if ~any(strcmp(varargin,'length'))&any(ans)
    varargin=[varargin,{'length'},{varargin{ans}*6}]; end
  varargin(find(strcmp(varargin,'linewidth')))={'width'}; % Width
  arrowproperties=[propertiesfor('arrow',varargin{:}),... 
                   propertiesfor('patch',varargin{:})];
  h(2)=arrow([x(end-1) y(end-1)],[x(end) y(end)],...
             'tag','bezierdraw',arrowproperties{:});    % Plot arrow
  % Move arrowhead to end of line (6th point is tail of arrow):
  xt=get(h(2),'xdata'); xs=(xt(3)+xt(9))/2; 
  dx=x(end)-xs; xt=xt([1:3 9:11])+dx;
  yt=get(h(2),'ydata'); ys=(yt(3)+yt(9))/2; 
  dy=y(end)-ys; yt=yt([1:3 9:11])+dy;
  % and removed body of arrow
  %
  % Merge line into arrow-patch:
%   w=complex(xt(4)-xt(5),yt(4)-yt(5)); % direction of xt-counting
%   a=complex(xt(1)-xt(5),yt(1)-yt(5));
%   %keyboard
%   W=abs(w)*sign((angle(w)-angle(a)))
  
%   %complex((xt(4)-xt(5)),(yt(4)-yt(5))); W=abs(ans)*sign(angle(ans));
%   clear i
%   dx=diff(x);         dy=diff(y); 
%   phi=angle(dx+i*dy); 
%   dx=-W*sin(phi);     dy=W*cos(phi);
%   x1=x(1:end-1)+dx;   y1=y(1:end-1)+dy; 
%   x2=x(1:end-1)-dx;   y2=y(1:end-1)-dy;
%   xt=[xt(1:3)',fliplr(x1),x2,xt(9:11)'];
%   yt=[yt(1:3)',fliplr(y1),y2,yt(9:11)'];
  set(h(2),'xdata',xt,'ydata',yt);
  %
%  delete(h(1));        h=h(2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [h,x,y]=draw()
poi=get(gcf,'pointer'); set(gcf,'pointer','cross');     % figure presets
xmod=get(gca,'xlimmode'); ymod=get(gca,'ylimmode');
set(gca,'xlimmode','manual','ylimmode','manual');

[X,Y,NX,NY,xx,yy,nxx,nyy,hp,hab,nh]=deal([]);           % Init variables
N=20;
% x,y           Nodes
% X,Y           Total points in order, both nodes and ruler-ends [a,x,b]
% NX,NY         Last three/new total points
% xx,yy         Main curve
% nxx,nyy       Last/new curve segment

k=waitforbuttonpress;                                   % First point
button='normal';
get(gca,'currentpoint'); x=ans(1,1);y=ans(1,2);
                                                        % Init plots
h=line(x,y,'tag','bezierdraw');                           % :main curve
nh=line(x,y,'marker','.');                                % :last segment
hp=line(x,y,'linestyle','none','marker','o','color','r'); % :red nodes
hab=line(x,y,'linestyle',':','marker','.','color','g');   % :green ruler
set([h,nh,hab],'xdata',[],'ydata',[]);                    % only node visible

k=waitforbuttonpress;                                   % Next point
oldbutt=button;  button=get(gcf,'selectiontype');       
get(gca,'currentpoint'); px=ans(1,1);py=ans(1,2);       
while ~k                                                % LOOP:
  switch button
   case 'normal'                                % NODE:
    if strcmp(oldbutt,button)                   
      x(end)=px;                y(end)=py;      % Just a changed node
    else
      x=[x,px];                 y=[y,py];       % New node after ruler
      X=[X,NX];                 Y=[Y,NY];       % Update data
      xx=[xx,nxx];              yy=[yy,nyy];    % 
      nxx=[];                   nyy=[];         %
      set(h,'xdata',xx,'ydata',yy);             % Update main curve
    end
    set(hp,'xdata',x,'ydata',y);                % Update node
   case 'alt'                                           
    bx=px;                      by=py;                  % RULER:
    ax=[x(end)-(bx-x(end))];    ay=[y(end)-(by-y(end))];% Find ruler data
    set(hab,'xdata',[ax bx],'ydata',[ay by]);           % Plot ruler
    %
    NX=[ax,x(end),bx];          NY=[ay,y(end),by];      % Last three total
    if length(X)>2                                      % Create new segment
      x4=[X(end-1:end) NX(1:2)]; y4=[Y(end-1:end) NY(1:2)];     %
      courbeb([x4;y4],N+1); nxx=ans(1,2:end); nyy=ans(2,2:end); %
      set(nh,'xdata',nxx,'ydata',nyy);                          %
    end                                                         %
  end
  k=waitforbuttonpress;                                 
  if k==1 & strcmp(char(27),get(gcf,'currentcharacter'))% ESC PRESSED:
    if length(x)>1              % erase one point back
      button='alt';
      px=X(end);        py=Y(end);
      X=X(1:end-3);     Y=Y(1:end-3);
      nxx=[];           nyy=[];
      xx=xx(1:end-N);   yy=yy(1:end-N);
      x=x(1:end-1);     y=y(1:end-1);   
    else                        % erase first point = return to scratch
      button='normal'; 
      [X,Y,NX,NY,xx,yy,nxx,nyy]=deal([]);
      x=x(1);           y=y(1);
      set(hab,'xdata',[],'ydata',[]);
      px=x;             py=y;                           % Next loop is
      oldbutt=button;                                   % just an update
    end
    set(nh,'xdata',nxx,'ydata',nyy);
    set(h,'xdata',xx,'ydata',yy); 
    set(hp,'xdata',x,'ydata',y);        
    k=0;
  else                                                  % MOUSE CLICKED
    oldbutt=button;  button=get(gcf,'selectiontype');   % Next point
    get(gca,'currentpoint'); px=ans(1,1);py=ans(1,2);   %
  end
end

delete(nh,hp,hab);                              % Reset figure
set(gcf,'pointer',poi);
set(gca,'xlimmode',xmod,'ylimmode',ymod);

xx=[xx,nxx];    yy=[yy,nyy];                    % Format output
set(h,'xdata',xx,'ydata',yy);
x=xx;           y=yy;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MatBezier]=courbeb(Mat,N);
% [MatBezier] = CourbeB(Mat,N);
%
% Mat   une matrice de deux vecteurs : celui des abscisses et celui des
%       ordonnées. 
% N     le nombre de points à calculer pour chaque segment
%
% URL: http://servasi.insa-rouen.fr/~ndreuill/projetananum/
% Réalisé par Nicolas de Dreuille. 
% E-mail : Nicolas.de-Dreuille@insa-rouen.fr 

t=linspace(0,1,N);
for i=1:N
  [xp,yp]=Bezier(Mat,t(i));                                     %2
  xBezier(i)=xp;
  yBezier(i)=yp;
end
MatBezier=[xBezier;yBezier];

% Bezier.m Permet de calculer un point de la courbe de Bézier 
% définie par n points de contrôle  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%2

function [xpoint,ypoint]=Bezier(Mat,t);
x=Mat(1,:);
y=Mat(2,:);
for j=(length(x)-1):-1:1
  for i=1:j
    x(i)=(1-t)*x(i)+t*x(i+1);
    y(i)=(1-t)*y(i)+t*y(i+1);
  end
end
xpoint=x(1);
ypoint=y(1);

% Binterp.m : Permet d'interpoler un ensemble de points avex
% l'approximation de Bézier.  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out=propertiesfor(type,varargin)
% PROPERTIESFOR Extract relevant graphics object properties
% from a cellstring of arbitrary property/value pairs. This makes it
% possible to create functions with a global input of property/value
% pairs to be passed on to different types of graphics objects.
%
% out = propertiesfor(type,varargin)
%
% type          = Object type string.
% varargin      = Cellstring with arbitrary property/value-pairs from which to
%                 extract relevant pairs for this object type. Property-names
%                 must be complete!
% out           = Cellstring with relevant property/value-pairs
%
% EXAMPLE:      lineproperties = propertiesfor('line',varargin{:});
%               set(h,lineproperties{:});  % h is handle to line-object
%               
% INVERSE search for properties  _not_ relevant for given object is
% possible with a '~' preceeding the object string (i.e. type='~line').
%
% Properties defined for all Matlab Graphics object types, as well as
% for properties of arrow
%
% See also HELPDESK -> Handle Graphics Objects

inverse=0;
if any(findstr('~',type))               % inverse or regular search
  inverse=1; type=type(2:end);  
end
  
type=lower(type);

props=get_props(type);                  % Define relevant properties 

if isempty(varargin), out=varargin{:}, return; end
  
for i=1:length(varargin)                % Ensure all lower case input
  varargin{i}=lower(varargin{i});
end

for i=1:length(props)                   % Find matches
  ii(i,:)=strcmp(varargin,props(i));
end

j=any(ii);                              % indices for relevant properties
if inverse
  j=find(all(~[j;[0 j(1:end-1)]]));     % indices for pairs not relevant
else
  j=find(any([j;[0 j(1:end-1)]]));      % indices for relevant pairs 
end

out=varargin(j);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Define relevant properties %%%%
function props=get_props(type)
switch type                             
 case 'line'
  props={'color','erasemode','linestyle','linewidth','marker','markersize','markeredgecolor','markerfacecolor','xdata','ydata','zdata','buttondownfcn','children','clipping','createfcn','deletefcn','busyaction','handlevisibility','hittest','interruptible','parent','selected','selectionhighlight','tag','type','uicontextmenu','userdata','visible'};  
 case 'patch'
  props={'cdata','cdatamapping','facevertexcdata','edgecolor','erasemode','facecolor','faces','linestyle','linewidth','marker','markeredgecolor','markerfacecolor','markersize','vertices','xdata','ydata','zdata','facelighting','edgelighting','backfacelighting','ambientstrength','diffusestrength','specularstrength','specularexponent','specularcolorreflectance','vertexnormals','normalmode','buttondownfcn','children','clipping','createfcn','deletefcn','busyaction','handlevisibility','hittest','interruptible','parent','selected','selectionhighlight','tag','type','uicontextmenu','userdata','visible'};
 case 'arrow'
  props={'start','stop','length','baseangle','tipangle','width','page','crossdir','normaldir','ends','objecthandles'};
end

