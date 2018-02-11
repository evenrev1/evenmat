function [i,x,h]=identify(hf)
% IDENTIFY	Identification of datapoint in plot
%
% [i,x,h] = identify(hf)
%
% hf	= handle to figure to operate on (default = current figure)
%
% i	= index of this point in the data-vector
% x	= three-element vector of coordinates of the found datapoint
% h	= handle to the chosen line-object
%
% Waits for mouseclick on line-object, and finds the datapoint closest to
% the point clicked by mouse. For 3D-plots the mouseclick represents a line
% going from front to back of plot.
%
% Use button 1 (B1, right handed left button) to select point on
% line. Clicking B2 (Control-B1) returns empty output arguments, both
% together (Shift-B1) return NaNs, and doubleclick any button returns 999 on
% all outarguments.
% 
% See also HELPDESK  
%          "Handle Graphics ObjectProperties" > Axis > CurrentPoint

if nargin<1|isempty(hf),        hf=gcf;         end

[h,x,i]=deal([]);			% Init output arguments

while ~strcmp(get(h,'type'),'line')	% Wait for click on a line-object 
  waitfor(hf,'currentpoint');
  button=get(hf,'selectiontype');
  if strcmp(button,'alt')		%'alt'	  = b2 | C-b1
    [h,x,i]=deal([]); return;
  elseif strcmp(button,'extend')	%'extend' = both | S-b1
    [h,x,i]=deal(NaN); return;
  elseif strcmp(button,'open')		%'open'	  = doubleclick
    [h,x,i]=deal(999); return;
  else
    h=gco;
  end
end

ax=findobj(get(h,'parent'),'type','axes');%Find parent axis of line

v=get(ax,'currentpoint');		% Get data for mousepoint

x=get(h,'xdata');			% Find vectors for line-data
y=get(h,'ydata'); 
z=get(h,'zdata');
if isempty(z), z=zeros(size(x)); end    % if xy-plot make bogus z-vector

% normalise data for mouseclick identification (capitalised variables)
get(ax,'xlim'); dx=diff(ans); X=(x-ans(1))/dx; V(:,1)=(v(:,1)-ans(1))/dx;
get(ax,'ylim'); dy=diff(ans); Y=(y-ans(1))/dy; V(:,2)=(v(:,2)-ans(1))/dy;
get(ax,'xlim'); dz=diff(ans); Z=(z-ans(1))/dz; V(:,3)=(v(:,3)-ans(1))/dz;

% Use vector algebra to estimate distances to mouseclick line trough
% graph:
cv=[(V(1,1)-V(2,1)) (V(1,2)-V(2,2)) (V(1,3)-V(2,3))];% point-vector
c=sqrt(sum(cv.^2));                             %length of point-vector
for j=1:length(x)
  av=[(X(j)-V(1,1)) (Y(j)-V(1,2)) (Z(j)-V(1,3))];% vector to datapoint
  d(j)=sqrt(sum(cross(cv,av).^2))/c;             % d = |c x a| / c
end

[ans,i]=min(d);                 % least distance=nearest to point-line

x=[x(i) y(i) z(i)];             % the coordinates of chosen point


%      datapoint                                                  
%         o	
%        /|                             
%       / | 
%    av/  |d                            d = |cv x av| / c 
%     /   |
%    /    |               cv
%   o----------------------->o
% Current       c       Current
% Point                 Point
% Front                 Back
