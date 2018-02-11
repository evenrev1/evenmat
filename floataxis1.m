function [hl1,ax1] = floataxis1(x,y,xy,lty,lab,axlim)
% FLOATAXIS1    first plot when using FLOATAXIS-functions
% Makes plot with same axistypes as the FLOATAXIS-functions. This is not
% necessary, but it's an easier way of making that first plot to add the
% floataxes to. The arguments are the same as in FLOATAXISX/Y, except for
% the xy-argument in between there.
%
% [hl1,ax1] = floataxis1(x,y,xy,lty,lab,axlim)
%
% x,y   = variables to be plotted (corresponds to x- and y-axis) (required)
% xy    = 'x' or 'y', to which axis will the floataxes be added?
% lty   = linetype-string
% lab   = axis label for the floataxis-side                      
% axlim = axis limits (optional adjustment)                      
%
% hl1   = handle(s) to plot-line(s)
% ax1   = handle to current (first) axis
%
% See also FLOATAXISY FLOATAXISX 

%An additional function to the floataxis-set by greenanb@mar.dfo-mpo.gc.ca
%http://www.maritimes.dfo.ca/science/ocean/epsonde/matlab.html
%Time-stamp:<Last updated on 06/09/14 at 11:31:29 by even@nersc.no>
%File:</home/even/matlab/evenmat/floataxis1.m>

error(nargchk(2,6,nargin));
if nargin < 6 | isempty(axlim)
  axlim=[];
end
if nargin < 5 | isempty(lab)
  lab='';
end
if nargin < 4 | isempty(lty)
  lty='k-';
end
if nargin < 3 | isempty(xy)
  xy='y';
end
if ~isvec(x) | ~isvec(y)
  error('x and y must be vectors!');
end

% plot
hl1=plot(x,y,lty);
% assign current axis handle to variable for later reference if needed
ax1=gca;
% set properties of the axes
eval([ 'set(ax1,''',xy,'MinorTick'',''on'',''box'',''on'',''',xy,'color'',get(hl1,''color''))']);
% add label to axis
eval([xy,'label(lab)']);







