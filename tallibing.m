function h=tallibing(x,y,n,size,color,opt)
% TALLIBING     numbers on field-plot
% Writes the numbers in a matrix as text at the positions given by the x and
% y coordinate matrices.
%
% h=tallibing(x,y,n,size,color,opt)
%
% x,y    = position matrices
% n      = the corresponding matrix of the values to be written
%          (non-integers are rounded)
% size   = font size (optional) (default=8)
% color  = color of text (optional) (default='white')
% opt    = options string:  'm_map'	= lon/lat positions in an m_map
%
% h      = column-vector of handles to tallibing's TEXT objects
%
% USAGE: Adding the numeric values of a datafield on top of a graph. Also,
% when plotting binned results, the number of datapoints in each bin can be
% written in the bins on the graph.
%
% EXAMPLE: [x,y,z]=peaks(20); epcolor(x,y,z); tallibing(x,y,z);
%		             ( pcolor(x,y,z); shading interp; )
%
% See also TEXT TALLIBING3

%Time-stamp:<Last updated on 06/05/02 at 17:14:45 by even@nersc.no>
%File:</home/even/matlab/evenmat/tallibing.m>

error(nargchk(3,6,nargin));
if nargin < 6 | isempty(opt),	opt='';		end
if nargin < 5 | isempty(color), color='w';	end
if nargin < 4 | isempty(size),  size=8;		end

if (isvec(x) | isvec(y)) & ~isvec(n)
  [x,y]=meshgrid(mat2vec(x),mat2vec(y));
end

x=x(:); y=y(:); n=n(:);
n=round(n);

oldtall=findobj(get(gca,'children'),'Tag','tallibing');
if any(oldtall), delete(oldtall); end

if any(findstr(opt,'m_map')),   [x,y]=m_ll2xy(x,y); end	% OPTION CHECK

for i=1:length(y)
  if any(n(i))
    h=text(x(i),y(i),int2str(n(i)),...
           'HorizontalAlignment','center','FontWeight','demi',...
           'FontSize',size,'Color',color,...
	   'Clipping','on',...
	   'Tag','tallibing');
  end
end
