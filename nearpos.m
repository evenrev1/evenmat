function [dx,dt,I,J] = nearpos(LONG,LAT,T,long,lat,t,mdx,mdt,pri)
% NEARPOS	Nearest geographical-temporal neighbours
% 
% [dx,dt,I,J] = nearpos(LONG,LAT,T,long,lat,t,mdx,mdt,pri)
% 
% LONG,LAT = Scalar or vector with the main set of positions.
% T        = Matlab serial day times for the main set of positions.
% long,lat = vectors with the other set of positions.
% t        = Matlab serial day times the other set of positions.
% mdx,mdt  = max limits for distance (km) and time (±days), to limit
%            the size of the set of other positions.
% pri      = fraction defining priority between distance and days
%            when sorting by 'nearness'. Values between 0-1,
%            where low puts priority on distance, high puts priority
%            on  time (default = 0.5 = 50/50 between days/km).
%
% dx       = MxN matrix of distances between the M main positions and
%            N other positions.
% dt       = matrix of time differences in the same format as dx.
% I        = subscripts to the rows of dx and dt for differences
%            inside the limits set by mdx and mdt, i.e. which main
%            positions has 'near neighbours' in the other positions.
% J        = subscripts to the columns of dx and dt for differences
%            inside the limits set by mdx and mdt, sorted by
%            'nearness' to each main position, i.e. which of the
%            other positions are the 'near neigbours'.
% 
% EXPLANATION: JJ=J(ismember(I,27)) returns indices for the other
% positions near enough to the 27th main position, sorted with the
% nearest first. So for [LONG(27),LAT(27),T(27)], the nearest neighbours
% are [long(JJ),lat(JJ),t(JJ)].
% 
% EXAMPLE: To collect all the near neighbours to each of M main
% positions, 	
%		for i=1:M
%		  JJ{i}=J(ismember(I,i));
%		end
%
% Requires SEAWATER  
%
% See also SW_DIST 

% Last updated: Wed Apr 19 23:11:28 2023 by jan.even.oeie.nilsen@hi.no

error(nargchk(5,9,nargin));
LONG=LONG(:); LAT=LAT(:); m=length(LONG); % main positions
long=long(:); lat=lat(:); n=length(long); % other positions
if nargin<9 | isempty(pri), pri=0.5; end
if nargin<8 | isempty(mdt), mdt=Inf; end
if nargin<7 | isempty(mdx), mdx=Inf; end
if nargin<6 | isempty(t),   t=nan(n,1); else, t=t(:); end
if            isempty(T),   T=nan(m,1); else, T=T(:); end

if any(diff([length(LONG) length(LAT) length(T)])), error('Main positions'' vectors must have same size!'); end
if any(diff([length(long) length(lat) length(t)])), error('Other positions'' vectors must have same size!'); end

[dx,dt]=deal(nan(m,n));	% matrices with individual 'distances'

for i=1:m % Loop main positions
  % Distances in space:
  lats=[repmat(LAT(i),1,n);lat']; longs=[repmat(LONG(i),1,n);long'];
  sw_dist(lats(:),longs(:),'km')'; 
  reshape([ans NaN],2,n); 
  dx(i,:)=ans(1,:);
  % Time differences:
  dt(i,:)=t'-T(i);
end
clear lats longs

% Indices to the distance matrices matching the criteria:
if     all(isnan(dx) | mdx==inf), JI=find(abs(dt) < mdt); % E.g., no dt-limit given 
elseif all(isnan(dt) | mdt==inf), JI=find(dx < mdx);	 % E.g., no dx-limit given 
else,				  JI=find(dx < mdx & abs(dt) < mdt);
end

% Find indexes for the nearest of the accepted:
[~,II]=sort((1-pri)*dx(JI)+pri*dt(JI)); % Sort the index after by 'distance' 
JI=JI(II);
[I,J]=ind2sub(size(dx),JI);	% Subscripts to the float-pos vs refdata-pos matrix:

% A 3D plot of it all:
if nargout==0
  figure; set(gcf,'position',get(0,'screensize')); clf;
  lim=[mima(LONG) mima(LAT)];
  tlim=mima(T,t);
  line(LONG,LAT,T,'marker','.','color','r');
  line(long,lat,t,'marker','.','linestyle','none');
  xlabel long; ylabel lat; grid; datetick('z',12,'keeplimits');
  %view([0 90])
  % Select the accepted other positions for each main position:
  JJ=nan(m,1);
  for i=1:m
    J(ismember(I,i));
    if any(ans)
      JJ(i)=ans(1); 
      line([long(JJ(i)) LONG(i)],[lat(JJ(i)) LAT(i)],[t(JJ(i)) T(i)],'color','g');
    end
  end
  ~isnan(JJ);
  line(long(JJ(ans)),lat(JJ(ans)),t(JJ(ans)),'marker','o','linestyle','none','color','r');
end
