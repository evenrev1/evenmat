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
 case 'text'
  props={'color','erasemode','editing','extent','fontangle','fontname','fontsize','fontunits','fontweight','horizontalalignment','position','rotation','string','units','interpreter','verticalalignment','buttondownfcn','children','clipping','createfcn','deletefcn','busyaction','handlevisibility','hittest','interruptible','parent','selected','selectionhighlight','tag','type','uicontextmenu','userdata','visible'};
 case 'surface'
  props={'cdata','cdatamapping','edgecolor','erasemode','facecolor','linestyle','linewidth','marker','markeredgecolor','markerfacecolor','markersize','meshstyle','xdata','ydata','zdata','facelighting','edgelighting','backfacelighting','ambientstrength','diffusestrength','specularstrength','specularexponent','specularcolorreflectance','vertexnormals','normalmode','buttondownfcn','children','clipping','createfcn','deletefcn','busyaction','handlevisibility','hittest','interruptible','parent','selected','selectionhighlight','tag','type','uicontextmenu','userdata','visible'};
 case 'rectangle'
  props={'curvature','erasemode','facecolor','edgecolor','linestyle','linewidth','position','buttondownfcn','children','clipping','createfcn','deletefcn','busyaction','handlevisibility','hittest','interruptible','parent','selected','selectionhighlight','tag','type','uicontextmenu','userdata','visible'};
 case 'light'
  props={'position','color','style','buttondownfcn','children','clipping','createfcn','deletefcn','busyaction','handlevisibility','hittest','interruptible','parent','selected','selectionhighlight','tag','type','uicontextmenu','userdata','visible'};
 case 'image'
  props={'cdata','cdatamapping','erasemode','xdata','ydata','buttondownfcn','children','clipping','createfcn','deletefcn','busyaction','handlevisibility','hittest','interruptible','parent','selected','selectionhighlight','tag','type','uicontextmenu','userdata','visible'}; 
 case 'uicontextmenu'
  props={'callback','position','buttondownfcn','children','clipping','createfcn','deletefcn','busyaction','handlevisibility','hittest','interruptible','parent','selected','selectionhighlight','tag','type','uicontextmenu','userdata','visible'};
 case 'uimenu'
  props={'accelerator','callback','checked','enable','foregroundcolor','label','position','separator','buttondownfcn','children','clipping','createfcn','deletefcn','busyaction','handlevisibility','hittest','interruptible','parent','selected','selectionhighlight','tag','type','uicontextmenu','userdata','visible'};
 case 'uicontrol'
  props={'backgroundcolor','callback','cdata','enable','extent','fontangle','fontname','fontsize','fontunits','fontweight','foregroundcolor','horizontalalignment','listboxtop','max','min','position','string','style','sliderstep','tooltipstring','units','value','buttondownfcn','children','clipping','createfcn','deletefcn','busyaction','handlevisibility','hittest','interruptible','parent','selected','selectionhighlight','tag','type','uicontextmenu','userdata','visible'};
 case 'axes'
  props={'ambientlightcolor','box','cameraposition','camerapositionmode','cameratarget','cameratargetmode','cameraupvector','cameraupvectormode','cameraviewangle','cameraviewanglemode','clim','climmode','color','currentpoint','colororder','dataaspectratio','dataaspectratiomode','drawmode','fontangle','fontname','fontsize','fontunits','fontweight','gridlinestyle','layer','linestyleorder','linewidth','nextplot','plotboxaspectratio','plotboxaspectratiomode','projection','position','ticklength','tickdir','tickdirmode','title','units','view','xcolor','xdir','xgrid','xlabel','xaxislocation','xlim','xlimmode','xscale','xtick','xticklabel','xticklabelmode','xtickmode','ycolor','ydir','ygrid','ylabel','yaxislocation','ylim','ylimmode','yscale','ytick','yticklabel','yticklabelmode','ytickmode','zcolor','zdir','zgrid','zlabel','zlim','zlimmode','zscale','ztick','zticklabel','zticklabelmode','ztickmode','buttondownfcn','children','clipping','createfcn','deletefcn','busyaction','handlevisibility','hittest','interruptible','parent','selected','selectionhighlight','tag','type','uicontextmenu','userdata','visible'};
 case 'figure'
  props={'backingstore','closerequestfcn','color','colormap','currentaxes','currentcharacter','currentobject','currentpoint','dithermap','dithermapmode','doublebuffer','filename','fixedcolors','integerhandle','inverthardcopy','keypressfcn','menubar','mincolormap','name','nextplot','numbertitle','paperunits','paperorientation','paperposition','paperpositionmode','papersize','papertype','pointer','pointershapecdata','pointershapehotspot','position','renderer','renderermode','resize','resizefcn','selectiontype','sharecolors','units','windowbuttondownfcn','windowbuttonmotionfcn','windowbuttonupfcn','windowstyle','buttondownfcn','children','clipping','createfcn','deletefcn','busyaction','handlevisibility','hittest','interruptible','parent','selected','selectionhighlight','tag','type','uicontextmenu','userdata','visible'};
 case 'root'
  props={'callbackobject','language','currentfigure','diary','diaryfile','echo','errormessage','fixedwidthfontname','format','formatspacing','pointerlocation','pointerwindow','recursionlimit','screendepth','screensize','showhiddenhandles','units','buttondownfcn','children','clipping','createfcn','deletefcn','busyaction','handlevisibility','hittest','interruptible','parent','selected','selectionhighlight','tag','type','uicontextmenu','userdata','visible'};
 case 'arrow'
  props={'start','stop','length','baseangle','tipangle','width','page','crossdir','normaldir','ends','objecthandles'};
end

