function deg=deg2num(d,m,s)
% DEG2NUM       deg,min,sec ordinates into decimal ordinates
%
% deg = deg2num(d,m,s)
%
% d,m,s = degree,minutes,seconds for an ordinate
% deg   = decimal degree ordinate
%
% The sign of d determines sign (west and south is negative) of 
% input, so the sign of m and s is irrelevant, for 
%
%	5°30'50"W , DEG2NUM(-5,-30,-50) = DEG2NUM(-5,30,50) = -5.5139
%
% See also POS2STR DEG2CART

%Time-stamp:<Last updated on 02/10/21 at 11:08:58 by even@gfi.uib.no>
%File:<d:/home/matlab/deg2num.m>

% Input tests:
error(nargchk(1,3,nargin));
[M,N]=size(d);
if nargin<3 | isempty(s), s=zeros(M,N); end
if nargin<2 | isempty(m), m=zeros(M,N); end
if ~isnumeric([d(:);m(:);s(:)])
  error('Numeric input only!');
%elseif ismatrix(d) | ismatrix(m)| ismatrix(s)
%  error('Single or vector input only!');
elseif any(d<-180) | any(180<d)
  error('Bad numbers (degrees outside [-180,180])!');
elseif length(m)~=length(d)| length(m)~=length(s)
  error('All input must have same length (matrices same size)!');
end

m=reshape(m,M,N); s=reshape(s,M,N);

find(d<0); m(ans)=-abs(m(ans)); s(ans)=-abs(s(ans));

seconds=3600*d+60*m+s;
deg=seconds/3600;

