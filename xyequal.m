function xyequal()
% XYEQUAL       AXIS EQUAL touching only x- and y-axis
% Sets x and y axis equal on 3D-plots. A substitute for AXIS EQUAL, since
% this function leaves the z-aksis alone. XYEQUAL does not tamper with the
% axis limits. 
%
% xyequal()
%
% See also AXIS

%Time-stamp:<Last updated on 00/06/30 at 14:38:01 by even@gfi.uib.no>
%File:<d:/home/matlab/xyequal.m>

aks=axis;
if length(aks)<6
  error('XYAXIS is for 3D plots only!')
end

lx=diff(aks(1:2));
ly=diff(aks(3:4));

get(gca,'PlotBoxAspectRatio');
set(gca,'PlotBoxAspectRatio',[lx/ly ly/lx ans(3)]);
