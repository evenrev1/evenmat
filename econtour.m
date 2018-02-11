function [c,h]=econtour(x,y,z,cont)
% ECONTOUR (incomplete)  b/w contourplot using whole and dashed lines.
% Whole-line-contours for positive levels, dashed for negative and dot-dash
% for the zero level (if present). 
%
% [c,h]=econtour(x,y,z,cont)
%
% Requires input of contourlevels! x and y coordinates may be omitted.
%
% See also CONTOUR

%Time-stamp:<Last updated on 01/10/03 at 10:09:56 by even@gfi.uib.no>
%File:<d:/home/matlab/econtour.m>

error(nargchk(2,4,nargin));

if nargin==2
  z=x;cont=y;x=[];x=[];y=[];
  if min(size(z))<2,error('z needs to be a matrix/field, not a vector!');end
  if min(size(cont))>1,error('cont needs to be a vector, not a matrix!');end
elseif nargin==3
  error('Either x,y,z,cont _or_ z,cont only must be given!');
end

neg=find(cont<0);nil=find(cont==0);pos=find(cont>0);
cneg=[];cnil=[];cpos=[];hneg=[];hnil=[];hpos=[];

%clf;
if isempty(x)|isempty(y)
  if ~isempty(neg),  [cneg,hneg]=contour(z,cont(neg),'k--');hold on;end
  if ~isempty(nil),  [cnil,hnil]=contour(z,cont(nil),'k-.');end
  if  isempty(neg),  hold on;end
  if ~isempty(pos),  [cpos,hpos]=contour(z,cont(pos),'k-');end
else % med x og y koordinater gitt
  if ~isempty(neg),  [cneg,hneg]=contour(x,y,z,cont(neg),'k--');hold on;end
  if ~isempty(nil),  [cnil,hnil]=contour(x,y,z,cont(nil),'k-.');end
  if  isempty(neg),  hold on;end
  if ~isempty(pos),  [cpos,hpos]=contour(x,y,z,cont(pos),'k-');end
end
hold off

c=[cneg cnil cpos];h=[hneg;hnil;hpos];