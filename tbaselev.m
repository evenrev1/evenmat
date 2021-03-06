function z = tbaselev(lon,lat,dl)
% TBASELEV      terrain elevation at geographical position(s)
% 
% z = tbaselev(lon,lat,dl)
% 
% lon,lat       Geographical position(s), vectors or arrays.
% dl            For every position the average elev is extracted from an
%               area of +- dl (in degrees) around the point. A
%               dl<0.09 results in a 3x3 points average, while larger
%               dl include more ETOPO5 points. (default=0.05)
% 
% z             mean elevation at each point in same size array as
%               input lon.
%
% See also M_ETOPO2 TBASESEC

error(nargchk(2,3,nargin));
if nargin<3 | isempty(dl), dl=.05; end

D=size(lon);
N=prod(D); %length(lon(:));
z=nans(D);
for i=1:N
%  elev=m_tbase([lon(i) lon(i) lat(i) lat(i)])
  %elev=m_tbase([lon(i)+dl*[-1 1] lat(i)+dl*[-1 1]]);
  %i
  %keyboard
  elev=m_etopo2([lon(i)+dl*[-1 1] lat(i)+dl*[-1 1]]);
  %size(elev);
  z(i)=mean(elev(:));
end

z=reshape(z,D);
