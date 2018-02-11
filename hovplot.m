function hovplot(t,x,z,cont,tlab,xlab,zlab,options)
% HOVPLOT       Hov-Möller-plot serving my needs and likings
%
% hovplot(t,x,z,cont,tlab,xlab,zlab,options)
%
% t       = the horizontal (time) axis 
% x       = the vertical (spatial) axis (usually depth)
% z       = the data-values to be contoured
% cont    = contourspecification
% t-/xlab = axis labels
% zlab    = label for the colorbar (may be used as title)
% options = string of option-letters...
%           'p' : shows the datapoint's positions in the t-x-space as points
%           'l' : shows the spatial positions of data as horizontal lines
%                 (for use when sampling is frequent)
% 
% See also CONTOURF ECOLORBAR

%Time-stamp:<Last updated on 00/06/30 at 14:36:44 by even@gfi.uib.no>
%File:<d:/home/matlab/hovplot.m>

error(nargchk(1,8,nargin));
if nargin < 8 | ~ischar(options),        options='';   end
if nargin < 7 | ~ischar(zlab),           zlab='';      end
if nargin < 6 | ~ischar(xlab),           xlab='space'; end
if nargin < 5 | ~ischar(tlab),           tlab='time';  end
if nargin < 4 | isempty(cont),           cont=[];      end
if nargin ==2 | isempty(t)
  error('z needs to be given! Check inarguments!');
end
if nargin ==1
  z=t; size(t); x=1:ans(1); t=1:ans(2);
end

if isempty(cont)                 % contourplot with robust cont-treatment
  contourf(t,x,z);
  ecolorbar(z,'t',zlab,1/70);
else
  contourf(t,x,z,cont);
  ecolorbar(cont,'t',zlab,1/70);
end

xlabel(tlab);ylabel(xlab);

if     findstr(options,'p')      % optional additions
  [t,x]=meshgrid(t,x);
  hold on;h=plot(t',x','k.');hold off;
elseif findstr(options,'l')
  [t,x]=meshgrid(t,x);
  hold on;plot(t',x','k');hold off;
end



