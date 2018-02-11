function h=mask(x,y,z)
% MASK		White out parts of plot
% Uses pcolor to put rectangular white surfaces over given coordinates in
% plot.
%
%  h = mask(x,y,z)
%
% x,y	= matrices of coordinates for the grid to mask. When masking a
%	  contourplot, this is the same as the X and Y used there.
% z	= A corresponding matrix indicating where to mask, non-nan and
%	  non-zero elements represent values to be masked.
%
% NB! Sets colormap to gray! Not so good when masking color graphs, but
% for the time being this how it is. If You are using BWCONT on contours
% in graph, use it _after_ MASK.
%
% See also EPCOLOR CONTOUR

%Time-stamp:<Last updated on 02/11/24 at 22:22:18 by even@gfi.uib.no>
%File:<d:/home/matlab/mask.m>
z(z==0)=nan;
z(~isnan(z)&z~=0)=0;

other=[findobj(gca,'type','patch'); ...
       findobj('type','surface')];
pr=get(other,'zdata');

if (iscell(pr)&~isempty([pr{:}])) | ~isempty(pr)
  [ans,over]=mima(pr); over=over+1;
else			
  over = 1;
end

hold on;
h=epcolor(x,y,z);set(h,'facecolor','flat','edgecolor','none'); 
hold off

set(h,'zdata',ones(size(z)+1)*over); 

%colormap gray;
%colormap; colormap(flipud(ans));

