function vprof(x,y,s,zakse)
% VPROF         vertical stick-profile (modified from Frank Nilsen)
% 
% vprof(x,y,s,zakse) or vprof(x,s,zakse)
%
% x,y   = velocity components. If complex velocity x, just omit y
% s     = line type specification
% zakse = z axis positions (vector)
%
% VPROF Velocity profile.
%
%       vprof(z,'s',zakse) og vprof(x,y,'s',zakse) bruker linjetypen 's' hvor
%       's' er en av de tillate linjetypene som beskrevet under PLOT komandoen.
%       Bruker plot3.
%       Denne funksjone plotter vektorene ut fra vinkler og soerrelser av
%       elementene i matrisene x og y. Vektoren zakse inneholder de verdiene
%       du vil ha langs z-aksen(f.eks. avstanden mellom stroemvektorene), og
%       maa ha lik lengde som X og Y. Alle argumentene maa alltid brukes.
%
%       Se ogsaa ESTICK, FEATHER,COMPASS, ROSE, QUIVER.

%modified from frank nilsen
%Time-stamp:<Last updated on 06/09/14 at 11:31:55 by even@nersc.no>
%File:</home/even/matlab/evenmat/vprof.m>

if ~isnumeric(x)
  error('x and y must be numeric or x must be imaginary!');
end
if any(~isreal(x))                % imaginary velocity (3 inargs)
  error(nargchk(1,3,nargin));
  if nargin < 3 | isempty(s)
    s=1:length(x);
  end    
  if nargin < 2 | isempty(y)
    y='r-';
  end
  zakse=s;
  s=y;
  y = imag(x); x = real(x);
elseif isreal(x) & isreal(y) % u and v component (4 inargs)
  error(nargchk(2,4,nargin));
  if nargin < 4 | isempty(zakse)
    zakse=1:length(x);
  end    
  if nargin < 2 | isempty(s)
    s='r-';
  end
end
 

xx = [0 1 1 1 1]';
yy = [0 0 0 0 0].';
arrow = xx + yy.*sqrt(-1);
[st,co] = colstyle(s);

% check and set argument dimensions
if isvec(zakse), zakse=zakse(:)';end
x = x(:);
y = y(:);
if length(x) ~= length(y)
   error('X og Y must be of equal length!');
 end
 
[m,n] = size(x);
z = (x + y.*sqrt(-1)).';
a = arrow * z;
mx = max(a(find(~isnan(a))));        

% Plotter vektorene
plot3(real(a), imag(a),ones(5,1)*zakse, s, [0 0],[0 0],[0 zakse(m)], s)
%set(gca,'zlim',[min(zakse) 0]);
grid;
%if strcmp('auto',axis('state'))
%       axis([0 mx [-mx mx]*.3]);
%end
%size(a)
%size(ones(5,1)*zakse) 






