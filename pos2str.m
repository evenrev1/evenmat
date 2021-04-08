function [lonstr,latstr]=pos2str(lon,lat,accuracy)
% POS2STR       transforms numeric positions into string-positions
% with point of the compass notation.
%
% [lonstr,latstr]=pos2str(lon,lat,accuracy)
%
% lon,lat  = single or vector numeric input of longitude and latitude
% accuracy = Optional integer, giving the resolution:
%            0 = degrees ; 1 = minutes ; 2 = seconds ;
%            If omitted or wrong the resolution will be automaticly chosen
%            according to the accuracy of the numeric lon and lat.
%
% lonstr,  = Mx1 cellstrings with rounded degrees and compass-notation
% latstr     If single outargument, the two are merget into one string.
%
% See also DEG2NUM DEG2CART

error(nargchk(2,3,nargin));                              % input-tests
if ~isnumeric(lon) | ~isnumeric(lat)
  error('Numeric input only!');
elseif ismat(lon) | ismat(lat)
  error('Single or vector input only!');
elseif any(lon<-180) | any(180<lon) | any(lat<-90) | any(90<lat)
  error('Bad numbers (outside -180<=lon<=180 & -90<=lat<=90)!');
end
if nargin<3|isempty(accuracy)|~isint(accuracy)|accuracy<0|accuracy>2
  if     isint(lon)     & isint(lat),    accuracy=0;
  elseif isint(lon*60)  & isint(lat*60), accuracy=1;
  else                                           accuracy=2;
  end
end
mf=60^accuracy;     % multiplying factor to find amount of smallest unit

lon=round(lon*mf);                  lat=round(lat*mf); 

% indices (which numbers are East, Median, West, North or South)
W=find(lon<0); M=find(lon==0); E=find(lon>0);
S=find(lat<0); Q=find(lat==0); N=find(lat>0);

% longitudes                        % latitudes
lonend={''};                        latend={''};
%lonend(W)=repstr('W',length(W));    latend(S)=repstr('S',length(S));
%lonend(M)=repstr('',length(M));     latend(Q)=repstr('',length(Q));
%lonend(E)=repstr('E',length(E));    latend(N)=repstr('N',length(N));
lonend(W)={'W'};                    latend(S)={'S'};
lonend(M)={''};                     latend(Q)={''};
lonend(E)={'E'};                    latend(N)={'N'};
lonend=lonend(:);                   latend=latend(:);

lon=abs(lon);                       lat=abs(lat);
lon=lon(:);                         lat=lat(:);


%dg=repstr(char(176),length(lon));   % ascii 176 = degrees
%mnt=repstr('''',length(lon));       %         ' = minutes
%s=repstr('"',length(lon));          %         " = seconds
dg={char(176)};                     % ascii 176 = degrees
mnt={''''};                         %         ' = minutes
s={'"'};                            %         " = seconds

% always make degrees
lond=floor(lon/mf);                 latd=floor(lat/mf);
% make minutes and seconds when needed
switch accuracy
  case 0
    lonstr=strcat(int2str(lond),dg,lonend); 
    latstr=strcat(int2str(latd),dg,latend); 
  case 1
    lonm=lon-lond*60;                   latm=lat-latd*60;
    lonstr=strcat(int2str(lond),dg,int2str(lonm),mnt,lonend); 
    latstr=strcat(int2str(latd),dg,int2str(latm),mnt,latend); 
  case 2
    lonm=floor((lon-lond*3600)/60);     latm=floor((lat-latd*3600)/60); 
    lons=lon-lond*3600-lonm*60;         lats=lat-latd*3600-latm*60;
    lonstr=strcat(int2str(lond),dg,int2str(lonm),mnt,int2str(lons),s,lonend); 
    latstr=strcat(int2str(latd),dg,int2str(latm),mnt,int2str(lats),s,latend); 
end

if nargout<2
%  repstr({' '},length(lonstr));
  lonstr=strcat(lonstr,{'  '},latstr);
end
