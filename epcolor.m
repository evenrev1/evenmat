function h=epcolor(x,y,data)
% EPCOLOR       a more correct PCOLOR (mid-bin positioning)
% The data-point-positions are in the middle of the bins instead of
% in the corners, and the last column and row of data are used.
%
% h = epcolor(x,y,data)
%
% [x,y]= the axes corresponding to the data-positions. Vectors or
%        matrices. If omitted, giving only data-matrix as inargument, the
%        matrix-indices are used as axes.
% data = data-matrix
%
% h    = handle to surface object
%
% Since the x- and ydata of surface object is shifted to fit PCOLOR, the
% centered x and y data is stored in object's UserData as 1x2 cell array.
%
% Example: [x,y,z]=peaks(20); epcolor(x,y,z);
%
% See also PCOLOR

%Time-stamp: <2000-06-29 18:43:42 even>
%File:</home/even/matlab/evenmat/epcolor.m>

error(nargchk(1,3,nargin));
if nargin==1
  data=x;
  [M,N]=size(data);
  x=1:N;
  y=1:M;
elseif nargin==3
  [M,N]=size(data);
  if min(size(x))~=1, x=x(1,:);  end
  if min(size(y))~=1, y=y(:,1)'; end
else
   error('EPCOLOR takes 3 or 1 inarguments! (x,y,data) or (data)')
end

% getting the right axes (askew [-dx,-dy] + add one at the ends)
[ans,xx]=buildgrid(x);
[ans,yy]=buildgrid(y);

% getting datamatrix right (add NaNs in extra row and column)
data(M+1,:)=nan;
data(:,N+1)=nan;

h=pcolor(xx,yy,data);

set(h,'userdata',{x,y});
addtag('epcolor',h);
