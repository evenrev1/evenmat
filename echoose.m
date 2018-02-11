function [xut,yut,vec]=echoose(x,y,data)
% ECHOOSE       choose row or column interactively on map
% In a map of a matrix/field choose a row or column with mousebuttons 1 or
% 2 respectively. This can be done on any axis-system representing the
% extent of the field. 
%
% Makes a plot of the chosen profile/vector in a figure numbered after the
% current figure. Put in a loop to examine profiles of the field.
%
% [xut,yut,vec]=echoose(x,y,data)
%
% x,y    = position matrices corresponding to the...
% data   = data matrix (the field)
%
% xu,yu  = the position-vectors in dimensions corresponding to ...
% vec    = the vector of chosen row or column (row or column dimension)
%
% See also GINPUT

%Time-stamp:<Last updated on 00/06/30 at 14:36:07 by even@gfi.uib.no>
%File:<d:/home/matlab/echoose.m>

[xx,yy,butt]=ginput(1);
if butt==1
  typ='row';
  [o,ii]=min(abs(y(:,1)-yy));vec=data(ii,:);xut=x(ii,:);yut=y(ii,:);
  xy=xut;scalar=yut(1);
else  
  typ='column';
  [o,ii]=min(abs(x(1,:)-xx));vec=data(:,ii);xut=x(:,ii);yut=y(:,ii);
  xy=yut;scalar=xut(1);
end

figprep(gcf+1,'profil');clf;

%plot(xy,vec);
erock(xy,vec);
if findstr(typ,'row')
  title(['latitude: ',num2str(scalar)]);
  xlabel('longitude')
else
  title(['longitude: ',num2str(scalar)]);
  xlabel('latitude')
end
figure(gcf-1) %go back to original figure

