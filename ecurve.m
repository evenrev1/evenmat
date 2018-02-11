function [h,coord]=ecurve(varargin)
% ECURVE	Draw by hand or plot curved lines and arrows.
% Two main characteristics of this function are:
% 1) DRAWING curves by hand, like the bezier-line drawing in
% Coreldraw. Simply click in plot with mouse to draw your line, alternating
% between making nodes (button 1), and aligning directional constrainment
% (button 2).
% 2) PLOTTING of curves/lines with arrowheads as well as patch design.
%
% [h,coord] = ecurve;
%
% Mouse-button 1  : Create points for line to pass through (nodes)
% Mouse-button 2  : End of tangential line at node (ruler)
%                   Create nodes and rulers alternately. Press same
%                   button again to redo last action. 
% ESC-key         : Undo
% Any other key   : Exit
%
% Input	= Parameter/value pairs to specify line properties (default is a
%         solid, black line), and option strings: 
%	    'arrow'	=>  An arrowhead (patch) is added to the line, using
%	                    the ARROW function. This is also achieved by
%	                    input of any ARROW parameter/value pair.
%	    'patch'     =>  Arrow is formed by one patch object.
%                           The advantage of having the whole arrow as a
%                           patch instead of a line with a patch
%                           arrowhead, is that patches can separate
%                           between EdgeColor and FaceColor, and have a
%                           wide range of face properties that can be
%                           used to make quite fancy arrows. However,
%                           such arrows can look strange in sharp bends.
%
%         Input can consist of any sequence of option strings and
%         parameter/value pair for for line, patch and ARROW objects.
%	  The parameters 'width' or 'linewidth' are identical, but
%	  the first initiates arrow since it is an arrow-property.
%	  The 'length' (of arrowhead) has a default relative to 'width'.
%         Input of line-vectors as values for 'xdata' and 'ydata'
%         gives plot of this line/arrow (without bezier-drawing).
%
% h	= matrix of handle(s) to drawn object(s) 
%         [line-handles,arrowhead-handles]
% coord	= cell array consisting of coordinate matrices in the format
%         [x;y] for the lines ([lon;lat] when in M_MAP axes)
%
% ASSIGNED OBJECT PROPERTIES:
% The following property values are given to an ECURVE object:
% 'tag'      = 'ecurve' to lines and whole patch arrows, and
%              'ecurvehead' to patch arrowheads at end of lines
% 'userdata' = the output array 'coord'. Given to lines and whole
%              patch arrows, not to arrowheads. Arrowheads get the
%              arrowhead property/value pairs in their userdata (so you
%              can draw similar arrow later).
% 
% PLOTTING CURVES AND ARROWS USING PRE-EXISTING COORDINATES:
% 'data': Coordinates can be input directly by giving the input
%         parameter name 'data' followed by a 2xN matrix of similar
%         design as the output 'coord', or a cell array of such matrices
%         for drawing several curves.
% 'file': Curve coordinates can be read from file and drawn, by giving
%         the input parameter 'file' followed by the filename for a
%         .mat file (without '.mat') containing an object as
%         described above with the name 'ecurves'. 
% 'axes': Curves drawn by ECURVE in one set of axes can be copied to
%         another by giving the input parameter name 'axes' followed
%         by the handle to the axes that contains curves. The curves
%         will be copied to the current axes. 
% Only the line coordinates can be retreived in this way, line and
% arrowhead specifications must be given explicitly. The saving or
% copying of ecurve coordinates can be useful for instance when
% plotting arrows depicting ocean currents om m_maps. The currents
% can in this way easily be redrawn onto maps of different sizes and
% projections.
%
% EXTRACTING AND STORING COORDINATES FROM PRE-DRAWN ECURVES:
% This is simple.  [h,coord] = ecurve('axes',gca); will extract and draw
% the same curves as already drawn in the current axes. Now You can save
% the output 'coord' in a .mat file. Remember delete(h) on the new
% curves to avoid duplicate curves in the same axes.
%
% CHANGING THE DESIGN OF PREVIOUSLY DRAWN CURVES:
% To change the appearance of curves or arrows (color, linewidth,
% baseangle, etc.) without having to redraw them manually, the 'axes'
% option can be used in the same way as described above: Make sure you
% have the handles to the original (unsatisfactory) curves. Use ECURVE
% again with the new style parameters and the option parameter 'axes'
% followed by the handle to the axes on which the changes are to be
% done. New curves will be drawn on top of the original ones.  Remember
% to delete(<handles>) the old curves.
%
% RELATED FUNCTIONS: 
%         One of the following functions is required for arrow-plot:
%         1) ARROW is part of MATDRAW, obtained at
%            ftp://ftp.mathworks.com/pub/contrib/v5/graphics/matdraw/
%	  2) MY_ARROW by Tore Furevik is obtained at
%	     www.gfi.uib.no/~even/matlab
%
%         M_MAP users can find the line's geographical positions as the
%         matrix [lon;lat] in get(h,'userdata').
% 
%         The bezier-algorithm included was kindly provided by Nicolas de
%         Dreuille (Nicolas.de-Dreuille@insa-rouen.fr) with explanation
%         on http://servasi.insa-rouen.fr/~ndreuill/projetananum/
%
% PROBLEMS: 
%	  - On non-linear axes rulers look strange, but drawing works OK
%	  - Making arrows is not safe on non-linear axes
%	  - One-patch arrows gets ugly at sharp bends and when crossing
%  	    itself
%
% EXAMPLE:  figure; clf; axes;
%           [h,coord] = ecurve('linewidth',20,'color','r');
%	    ecurve('data',coord,'width',15,...
%                  'patch','edgecolor','y','baseangle',120);
%	    ecurve('data',coord,'width',6,'linestyle','--',...
%		   'edgecolor','k','facecolor','g','patch','baseangle',70);
%
% See also ARROW MY_ARROW M_MAP GINPUT

% Revision history:
% 25/8-03 JEN	Added ability to input coordinates for more than
%		one ecurve, as well as grabbing ecurves from other
%		axes and direct input of file with ecurve data.

M=length(varargin);
for i=1:M				% Ensure all lower case input
  if iscell(varargin{i}), continue; end
  varargin{i}=lower(varargin{i});
end
axis(axis);				% Not to change axis limits
%----------------------------------------------------------------------
fi=find(strcmp(varargin,'file'));	% for line data input from .mat
ai=find(strcmp(varargin,'axes'));	% to grab ecurves from other axes
xi=find(strcmp(varargin,'data'));	% vector input of data
%yi=find(strcmp(varargin,'ydata'));	%  -"-
					% no data input means draw line
					
% Process input cases (order of priority):
if any(fi)				% DATA INPUT FROM .MAT FILE
  file=varargin{fi+1};
  %load(file,'coord'); 
  load(file); 
  if exist('ecurves'), coord=ecurves; clear ecurves; end
  varargin=varargin(setdiff(1:M,[fi,fi+1]));	% Remove file arguments
elseif any(ai)				% GRAB ECURVES FROM OTHER AXES
  ax=varargin{ai+1};
  oldarr=findobj(ax,'tag','ecurve');		% Find ecurve objects
  %set(oldarr,'color','r');			% Color to check
  coord=get(oldarr,'userdata');			% Put xy-data in variable
  varargin=varargin(setdiff(1:M,[ai,ai+1]));	% Remove axis arguments
elseif any(xi)%&any(yi)			% DIRECT DATA INPUT
  %  x=varargin{xi+1}; y=varargin{yi+1};  
  coord=varargin{xi+1};
  %  varargin=varargin(setdiff(1:M,[xi,xi+1,yi,yi+1]));	% remove x/y-data
  varargin=varargin(setdiff(1:M,[xi,xi+1]));	% Remove data arguments
end

%----Draw lines--------------------------------------------------------
if exist('coord')			% DATA HAS BEEN INPUT IN SOME WAY
  h=[];coor=[];
  if ~iscell(coord), coord={coord}; end
  for j=1:length(coord)
    x=coord{j}(1,:); y=coord{j}(2,:);
    try
      [xx,yy]=m_ll2xy(x,y);		% Assume lon/lat input and m_map
      if ~isempty(xx)&~all(isnan(xx))&~isempty(yy)&~all(isnan(yy))
	lon=x;lat=y;
	x=xx;y=yy;			% Yes, it was input as lon/lat
      end
    end
    findobj(gca,'tag','m_grid_box');
    ii=find(inpolygon(x,y,get(ans,'xdata'),get(ans,'ydata')));
    %ii=ii(3:end-2);
    if ~isempty(ii)
      x=x(ii); y=y(ii);
      h(end+1,1)=line('xdata',x,'ydata',y);		% plot line
      coor{end+1}=[x;y];
    end
  end
  coord=coor;	% New coord that only has arrows inside map frame
else					% NO DATA INPUT
  [h,x,y]=draw;					% drawing by hand
  coord={[x;y]};				
end
if length(x)<2, return; end   
% coord should now be in x,y and not lon,lat 
% All arrow design needs to be done in x,y-coordinates to get the
% right perspective, so use x,y in the following.
% (This should also make copying ecurves to current m_map robust.)
% Remember that lon/lat <-> x/y transformations are done with the
% latest (current) initiation of m_map projection, so current axes
% should be this m_map.

%-----Set some styles to the lines-------------------------------------
if ~any(strcmp(varargin,'color'))		% Add default styles:
  varargin=[varargin,{'color'},{'k'}];end
if ~any(strcmp(varargin,'linestyle'))
  varargin=[varargin,{'linestyle'},{'-'}];end
% 
lineproperties=propertiesfor('line',varargin{:}); % Which Lineproperties?

ww=find(strcmp(varargin,'width'))+1;				
lw=find(strcmp(varargin,'linewidth'))+1;	
 
if any(ww) % For the line, 'width' is the linewidth in any case
  lineproperties=[lineproperties,{'linewidth'},varargin(ww)]; 
end

% elseif ~any(w)&any(lw)				% should be equal
%   varargin(find(strcmp(varargin,'linewidth')))={'width'}; % Width
%   %varargin=[varargin,{'width'},varargin(lw)];	% if only one given
% end							

if ~isempty(lineproperties), set(h,lineproperties{:}); end % h(1)?
%----------------------------------------------------------------------
set(h,'tag','ecurve');	% set here in case arrow section returns

%-------Add arrowhead if requested------------------------------------>
% The following uses x and y a lot
if any(strcmp(varargin,'arrow'))|any(strcmp(varargin,'patch'))|...
      ~isempty(propertiesfor('arrow',varargin{:}))
  col=find(strcmp(varargin,'color'))+1;			  % Default colors
  if ~any(strcmp(varargin,'edgecolor'))			  
    varargin=[varargin,{'edgecolor'},varargin(col)]; 
  end
  if ~any(strcmp(varargin,'facecolor'))	     
    varargin=[varargin,{'facecolor'},varargin(col)]; 
  end
  if any(lw)&~any(ww)		      % 'linewidth' alone means 'width'
    varargin(find(strcmp(varargin,'linewidth')))={'width'};
    ww=lw;
  end
  if ~any(strcmp(varargin,'length')) & any(ww)		  % Default length
    varargin=[varargin,{'length'},{varargin{ww}*6}]; 
  end
  arrowproperties=[propertiesfor('arrow',varargin{:}),... % Get properties
		   propertiesfor('patch',varargin{:})];
  for j=1:length(coord)		% LOOP EACH ARROW
    x=coord{j}(1,:); y=coord{j}(2,:);
% No need to check for lon/lat input when coord is set to [x;y] above
    %     try					% In case of m_map 
%       [xx,yy]=m_ll2xy(x,y);		% Assume lon/lat input and m_map
%       if ~isempty(xx)&~all(isnan(xx))&~isempty(yy)&~all(isnan(yy))
% 	x=xx;y=yy;			% Yes input was given as lon/lat
%       end
%     end
    %
    try
      h(j,2)=arrow([x(end-1) y(end-1)],[x(end) y(end)],arrowproperties{:});
      xt=get(h(j,2),'xdata');	yt=get(h(j,2),'ydata');	% arrowhead data
    catch
      try
	if any(ww), WW=varargin{ww}; else WW=[]; end
	S=find(strcmp(varargin,'linestyle'))+1;	% has to be there (default)
	[h1,h2]=my_arrow(x,y,WW,[],varargin{S},varargin{col});
	delete(h(j,1)); h(j,1:2)=[h1,h2];		% Delete old line
	xt=get(h(j,2),'xdata');	yt=get(h(j,2),'ydata');	% Arrowhead data
	xt(1:2)=xt([2 1]);	xt(10:11)=xt([3 1]);	% Simulate 
	yt(1:2)=yt([2 1]);	yt(10:11)=yt([3 1]);    % ARROW type 
	(xt(2)+xt(10))/2;	xt(5:7)=[ans;ans;ans];  % of arrowhead
	(yt(2)+yt(10))/2;	yt(5:7)=[ans;ans;ans];  %
	(xt(2)+xt(5))/2;	xt(3:4)=[ans;ans];      %
	(yt(2)+yt(5))/2;	yt(3:4)=[ans;ans];	%
	(xt(7)+xt(10))/2;	xt(8:9)=[ans;ans];	%
	(yt(7)+yt(10))/2;	yt(8:9)=[ans;ans];      % 
	propertiesfor('line',varargin{:});  set(h(j,1),ans{:}); % update
	propertiesfor('patch',varargin{:}); set(h(j,2),ans{:}); % graphics
	%disp('Using MY_ARROW');
      catch
	disp('No ARROW or MY_ARROW functions found!');
	disp('A line is the best I can do.');
	return
      end
    end
    %
    if ~any(strcmp(varargin,'patch'))	% LINE+PATCH ARROW WANTED:
      xs=(3*(xt(3)+xt(9))+xt(1))/7;		% "neck" joint inside head
      ys=(3*(yt(3)+yt(9))+yt(1))/7;		% to accomodate lines ascew
      dx=x(end)-xs;		dy=y(end)-ys;		% Offset from line
      xt=xt([1:3 9:11])+dx;	yt=yt([1:3 9:11])+dy;	% New head data 
      set(h(j,2),'xdata',xt,'ydata',yt);		% Move head-patch
      set(h(j,2),'tag','ecurvehead',...			% Tag the head-patch
		 'userdata',arrowproperties);		% Shape-data in object
    else				% WHOLE PATCH ARROW WANTED:
    					% Move arrowhead to end of line:
      xs=(xt(4)+xt(8))/2;		ys=(yt(4)+yt(8))/2;	% "tail" point
      dx=x(end)-xs;		dy=y(end)-ys;		% offset from line
      xt=xt+dx;			yt=yt+dy;		% move head
      set(h(j,2),'xdata',xt,'ydata',yt);		%
      %%line(xt(4),yt(4),'marker','o');
      %%line(xt(5),yt(5),'marker','^');
     					% Merge line into arrow-patch:
      [xt,yt]=xy2pt(xt,yt); [x,y]=xy2pt(x,y); % normalize coordinates
      w=complex(xt(4)-xt(5),yt(4)-yt(5)); % direction of lowest head indices
      a=complex(xt(1)-xt(5),yt(1)-yt(5)); % direction arrow-point
      cross([real(a),real(w),0],[imag(a),imag(w),0]); % sign of line-offset
      W=abs(w)*sign(ans(3));			    % and length
      %%title([num2str(angle(a)),' : ',num2str(angle(w)),' : ',num2str(W)]);
      dx=diff(x);	dy=diff(y);	% dx,dy for each linepoint 
      phi=angle(complex(dx,dy));		% angle of each line-point
      dx=-W*sin(phi);	dy=W*cos(phi);	% offset at each line-point
      x1=x(1:end-1)+dx;	y1=y(1:end-1)+dy;  % "left" side of line
      x2=x(1:end-1)-dx;	y2=y(1:end-1)-dy;  % "right" side of line
      xt=[xt(1:3)',fliplr(x1),x2,xt(9:11)']; % new patch data (whole arrow) 
      yt=[yt(1:3)',fliplr(y1),y2,yt(9:11)']; %
      [xt,yt]=xy2pt(xt,yt,'inverse');	% re-transform coordinates
      [x,y]=xy2pt(x,y,'inverse');	%
      set(h(j,2),'xdata',xt,'ydata',yt);% update patch
      delete(h(j,1));	h(j,1)=h(j,2);	% delete line and copy handle 
      %%text(xt,yt,cellstr(int2str([1:length(xt)]')),...
      %%     'horizontalalignment','center');
      set(h(j,1),'tag','ecurve');	% Tag this whole arrow-patch
    end 
    % <--------------------------------------------------Arrow------------
  end
end

% MUST LOOP
% possibly needed: if whole patch arrow, h=h(:,2); only patch handle
% on the other hand, whole patch arrows can have Mx2 handles for robustness

% OUTPUT AND USERDATA: 
% Now it is safe to change coord. In the above all arrow design had to
% be in x,y to get the right perspective.
for j=1:length(coord)			% LOOP EACH ECURVE
  x=coord{j}(1,:); y=coord{j}(2,:);
  try					% In case of m_map
    [lon,lat]=m_xy2ll(x,y);		% Assume m_map
    if ~isempty(lon)&~all(isnan(lon))&~isempty(lat)&~all(isnan(lat))
      coord{j}=[lon;lat];		% make lon,lat coordinate matrix
    end
  end
  if size(h,2)>1
    set(h(j,2),'userdata',[]);		% clear userdata in arrowheads
  end
  set(h(j,1),'userdata',coord{j});	% save coordinates in ecurves
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [h,x,y]=draw()
poi=get(gcf,'pointer'); set(gcf,'pointer','cross');	% figure presets
xmod=get(gca,'xlimmode'); ymod=get(gca,'ylimmode');
set(gca,'xlimmode','manual','ylimmode','manual');

[X,Y,NX,NY,xx,yy,nxx,nyy,hp,hab,nh]=deal([]);		% Init variables
N=20;
% x,y		Nodes
% X,Y		Total points in order, both nodes and ruler-ends [a,x,b]
% NX,NY		Last three/new total points
% xx,yy		Main curve
% nxx,nyy	Last/new curve segment

k=waitforbuttonpress;					% First point
button='normal';
get(gca,'currentpoint'); x=ans(1,1);y=ans(1,2);
							% Init plots
h=line(x,y);						  % :main curve
nh=line(x,y,'marker','.');				  % :last segment
hp=line(x,y,'linestyle','none','marker','o','color','r'); % :red nodes
hab=line(x,y,'linestyle',':','marker','.','color','g');	  % :green ruler
set([h,nh,hab],'xdata',[],'ydata',[]);			  % only node visible

k=waitforbuttonpress;					% Next point
oldbutt=button;	 button=get(gcf,'selectiontype');	
get(gca,'currentpoint'); px=ans(1,1);py=ans(1,2);	
while ~k						% LOOP:
  switch button
   case 'normal'				% NODE:
    if strcmp(oldbutt,button)			
      x(end)=px;		y(end)=py;	% Just a changed node
    else
      x=[x,px];			y=[y,py];	% New node after ruler
      X=[X,NX];			Y=[Y,NY];	% Update data
      xx=[xx,nxx];		yy=[yy,nyy];	% 
      nxx=[];			nyy=[];		%
      set(h,'xdata',xx,'ydata',yy);		% Update main curve
    end
    set(hp,'xdata',x,'ydata',y);		% Update node
   case 'alt'						
    bx=px;			by=py;			% RULER:
    ax=[x(end)-(bx-x(end))];	ay=[y(end)-(by-y(end))];% Find ruler data
    set(hab,'xdata',[ax bx],'ydata',[ay by]);		% Plot ruler
    %
    NX=[ax,x(end),bx];		NY=[ay,y(end),by];	% Last three total
    if length(X)>2					% Create new segment
      x4=[X(end-1:end) NX(1:2)]; y4=[Y(end-1:end) NY(1:2)];	%
      courbeb([x4;y4],N+1); nxx=ans(1,2:end); nyy=ans(2,2:end);	%
      set(nh,'xdata',nxx,'ydata',nyy);				%
    end								%
  end
  k=waitforbuttonpress;					
  if k==1 & strcmp(char(27),get(gcf,'currentcharacter'))% ESC PRESSED:
    if length(x)>1		% erase one point back
      button='alt';
      px=X(end);	py=Y(end);
      X=X(1:end-3);	Y=Y(1:end-3);
      nxx=[];		nyy=[];
      xx=xx(1:end-N);	yy=yy(1:end-N);
      x=x(1:end-1);	y=y(1:end-1);	
    else			% erase first point = return to scratch
      button='normal'; 
      [X,Y,NX,NY,xx,yy,nxx,nyy]=deal([]);
      x=x(1);		y=y(1);
      set(hab,'xdata',[],'ydata',[]);
      px=x;		py=y;				% Next loop is
      oldbutt=button;					% just an update
    end
    set(nh,'xdata',nxx,'ydata',nyy);
    set(h,'xdata',xx,'ydata',yy); 
    set(hp,'xdata',x,'ydata',y);	
    k=0;
  else							% MOUSE CLICKED
    oldbutt=button;  button=get(gcf,'selectiontype');	% Next point
    get(gca,'currentpoint'); px=ans(1,1);py=ans(1,2);	%
  end
end

delete(nh);delete(hp);delete(hab);		% Reset figure
set(gcf,'pointer',poi);
set(gca,'xlimmode',xmod,'ylimmode',ymod);

xx=[xx,nxx];	yy=[yy,nyy];			% Format output
set(h,'xdata',xx,'ydata',yy);
x=xx;		y=yy;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MatBezier]=courbeb(Mat,N);
% [MatBezier] = CourbeB(Mat,N);
%
% Mat	une matrice de deux vecteurs : celui des abscisses et celui des
%	ordonnées. 
% N	le nombre de points à calculer pour chaque segment
%
% URL: http://servasi.insa-rouen.fr/~ndreuill/projetananum/
% Réalisé par Nicolas de Dreuille. 
% E-mail : Nicolas.de-Dreuille@insa-rouen.fr 

t=linspace(0,1,N);
for i=1:N
  [xp,yp]=Bezier(Mat,t(i));					%2
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X,Y]=xy2pt(x,y,inv,h);
% XY2PT		Transform coordinates in data units to points 
%
% [X,Y] = xy2pt(x,y,inv,h);
%
% x,y	= Vectors/arrays of data coordinates in reference axes
% inv	= Any non-empty input gives the inverse transformation (from
%         points to data units of reference axes) 
% h	= Handle to reference axis (default = current axes)
%
% X,Y	= Vectors/arrays of coordinates in points relative to axis origo
%
% The transformation is based on the position and data ranges of the
% reference axis. The point-coordinates are relative to axis origo.  Now
% angles and relative distances of graphics can be calculated.  The results
% can then be transformated back into the original coordinates by inverse
% XY2PT.  The need for this function comes from the lack of position
% information other than in data units, on plotted objects.
%
% PROBLEMS: Does not work on nonlinear axes
%
% See also AXIS XLIM YLIM

error(nargchk(2,4,nargin));
if nargin<4|isempty(h),	  h=gca;		end

uni=get(h,'units');			% get units

set(h,'units','points'); get(h,'position');
dx=ans(3);		dy=ans(4);		% axis ranges in points

xr=get(h,'xlim');	yr=get(h,'ylim');
Dx=xr(2)-xr(1);		Dy=yr(2)-yr(1);		% axis ranges in data units

if nargin<3|isempty(inv)
  X=(x-xr(1))/Dx*dx;	Y=(y-yr(1))/Dy*dy;	% transformation
else
  X=x*Dx/dx+xr(1);	Y=y*Dy/dy+yr(1);	% inverse
end

set(h,'units',uni);			% reset units 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=propertiesfor(type,varargin)
% PROPERTIESFOR	Extract relevant graphics object properties
% from a cellstring of arbitrary property/value pairs. This makes it
% possible to create functions with a global input of property/value
% pairs to be passed on to different types of graphics objects.
%
% out = propertiesfor(type,varargin)
%
% type		= Object type string.
% varargin	= Cellstring with arbitrary property/value-pairs from which to
%                 extract relevant pairs for this object type. Property-names
%                 must be complete!
% out		= Cellstring with relevant property/value-pairs
%
% EXAMPLE:	lineproperties = propertiesfor('line',varargin{:});
%		set(h,lineproperties{:});  % h is handle to line-object
%		
% INVERSE search for properties  _not_ relevant for given object is
% possible with a '~' preceeding the object string (i.e. type='~line').
%
% Properties defined for all Matlab Graphics object types, as well as
% for properties of arrow
%
% See also HELPDESK -> Handle Graphics Objects

inverse=0;
if any(findstr('~',type))		% inverse or regular search
  inverse=1; type=type(2:end);	
end
  
type=lower(type);

props=get_props(type);			% Define relevant properties 

if isempty(varargin), out=varargin{:}, return; end
  
for i=1:length(varargin)		% Ensure all lower case input
  varargin{i}=lower(varargin{i});
end

for i=1:length(props)			% Find matches
  ii(i,:)=strcmp(varargin,props(i));
end

j=any(ii);				% indices for relevant properties
if inverse
  j=find(all(~[j;[0 j(1:end-1)]]));	% indices for pairs not relevant
else
  j=find(any([j;[0 j(1:end-1)]]));	% indices for relevant pairs 
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

% Erik A Johnson wrote:
%
% P.P.S. By the way, if you wanted to "dynamically" find which
% properties a particular built-in object has, you could use 
%
%    props = fieldnames(get(h));
%
% If you don't have an object already, create one
%
%    h = feval(type,'Visible','off');
%
% and delete it after you get the properties.  Of course, this
% doesn't work for an arrow object -- it would just return the patch
% properties. 
