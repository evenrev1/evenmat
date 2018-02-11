function h=cage(varargin)
% CAGE          plots point-grid from vectors
% Plots a 2D or 3D grid of lines (a cage) described by the input
% vectors. Normally used to show the bins used making binned-means.
%
% h = CAGE(x,y,(z))
%
% x,y   = vectors describing the positioning of the lines in their
%         respective dimension
% z     = if present, the grid is 3D (and plot has to be as well)
% 
% h     = column vector of handles to the LINE objects, one handle per
%         line, in the order left, right, bottom, top.
%
% Plot is held and released by CAGE, so to HOLD ON if plot is to stay
% held. 
%
% See also POINTS PLOT PLOT3 BIN

%Time-stamp:<Last updated on 06/09/14 at 11:31:17 by even@nersc.no>
%File:</home/even/matlab/evenmat/cage.m>

error(nargchk(2,4,nargin));             % input check
x=varargin{1}; y=varargin{2};
if all(~isvec(varargin)), error('At least one vector input, please!'); end
hold on; 
if nargin==3,  
  z=varargin{3}; 
  [X,Y]=meshgrid(x,y);
  for k=1:length(z)
    Z=repmat(z(k),size(X)); plot3(X,Y,Z,'k-'); plot3(X',Y',Z','k-'); 
  end
  [X,Z]=meshgrid(x,z);
  for i=1:length(y)
    Y=repmat(y(i),size(X)); plot3(X,Y,Z,'k-'); plot3(X',Y',Z','k-'); 
  end
else
  [X,Y]=meshgrid(x,y);
  h=plot(X,Y,'k-',X',Y','k-');
end
hold off;

  
