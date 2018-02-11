function h=points(x,y,varargin)
% POINTS        plots point-grid from vectors
% Plots a 2D or 3D grid of points described by the input
% vectors. Normally used to mark the positions of datapoints in
% contourplots etc.
%
% h = points(x,y,(z))
%
% x,y   = vectors describing the positioning of points in their
%         respective dimension
% z     = if present, the grid is 3D (and plot has to be as well)
%         
%         Input can be can be followed by parameter/value pairs to specify
%         additional properties of the lines.
%
% h     = column vector of handles to the LINE objects, one handle per
%         line 
%
% See also CAGE PLOT PLOT3

%error(nargchk(2,4,nargin));             % input check
%x=varargin{1}; y=varargin{2};
%if all(~isvec(varargin)), error('At least one vector input, please!'); end

%hold on; 
%if nargin==3,  
%  z=varargin{3}; 

if nargin>2 & isnumeric(varargin{1})
  z=varargin{1}; 
  [X,Y]=meshgrid(x,y);
  for k=1:length(z)
    Z=repmat(z(k),size(X));     h=plot3(X,Y,Z,varargin{2:end}); 
				%h=plot3(X,Y,Z,'k.','markersize',4); 
                                %plot3(X',Y',Z','k.','markersize',4); 
%  end
%  [X,Z]=meshgrid(x,z);
%  for i=1:length(y)
%    Y=repmat(y(i),size(X));    plot3(X,Y,Z,'k.','markersize',4); 
%                               plot3(X',Y',Z','k.','markersize',4); 
  end
else
  [X,Y]=meshgrid(x,y);
  %h=plot(X,Y,'k.','markersize',4); %plot(X',Y','k.','markersize',4);
%%%  h=plot(X,Y,'k.',varargin{:});
  h=line(X,Y);
  set(h,'color','k','marker','.','linestyle','none');
  if ~isempty(varargin)
    set(h,varargin{:});
  end
end
%hold off;

  
