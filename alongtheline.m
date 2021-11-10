function [I,PI] = alongtheline(x,y,lx,ly)
% ALONGTHELINE	Sort coordinate points along a line.
% 
% [I,PI] = alongtheline(x,y,lx,ly)
% 
% x,y	= vectors of coordinates that are to be sorted.
% lx,ly	= vectors of coordinates for the line x,y are to be sorted
%         along, 
% 
% I	= The index to x and y that sorts x,y points along the line and
%         in the same direction as described by lx,ly.
% PI	= The index to lx and ly of the nearest points on the line.
% 
% Plots a graph of the results when no output is requested.
% 
% See also KNNSEARCH SORT

% by Jan Even Øie Nilsen, https://github.com/evenrev1

% Idx = knnsearch( X , Y ) finds the nearest neighbor in X for each
% query point in Y and returns the indices of the nearest neighbors in
% Idx , a column vector. Idx has the same number of rows as Y.

error(nargchk(4,4,nargin));

Idx = knnsearch([lx(:),ly(:)],[x(:),y(:)]); % index for ln of nearest points to x,y
[PI,I] = sort(Idx,'ascend'); % Sort indexes (i.e., along the line).

if nargout==0
  findobj(0,'tag','alongtheline');
  if isempty(ans)
    f=figure; set(f,'tag','alongtheline','name','alongtheline');
  else
    figure(ans); clf;
  end
  h=line(lx,ly);%h=line(ln(:,1),ln(:,2));
  h1=line(x,y);
  h2=line(x(I),y(I));
  h3=line(lx(PI),ly(PI));%h3=line(ln(PI,1),ln(PI,2));
  h4=line([lx(PI),x(I)]',[ly(PI),y(I)]');
  set(h,'linestyle','none','marker','.','color','k')
  set(h1,'linestyle',':','marker','*')
  set(h2,'linestyle','-','marker','.','color','r')
  set(h3,'linestyle','none','marker','o','color','g')
  set(h4,'linestyle','-','marker','none','color','k')
  axis equal
  legend line xy xysorted nearestpoints connectors location best 
end


% -------- Method of adding islands to coast polygon: ----------------
% P=[norwaycoast_f(:,1),norwaycoast_f(:,2)];
% clear norwaycoast_f
% point and zoom on an island
% gco; set(ans,'edgecolor','r')
% p=ans.Vertices; [p(:,1),p(:,2)]=m_xy2ll(p(:,1),p(:,2));P=emerge(P,p);
% norwaycoast_f=P; % finally
% save norwaycoast norwaycoast_f -append
