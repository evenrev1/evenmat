function [dx,dt,I,J,JJ] = nearpos(LONG,LAT,T,long,lat,t,mdx,mdt,p)
% NEARPOS	Nearest geographical-temporal neighbours
% 
% [dx,dt,I,J,JJ] = nearpos(LONG,LAT,T,long,lat,t,mdx,mdt,p)
% 
% LONG,LAT = Scalar or vector with the main set of positions.
% T        = Matlab serial day times for the main set of positions.
% long,lat = vectors with the other set of positions.
% t        = Matlab serial day times the other set of positions.
% mdx,mdt  = max limits for distance (km) and time (±days), by which
%            to select other positions that are 'near' enough.
% p        = fraction defining priority between distance and days
%            when sorting the selected positions by 'nearness'. The
%            combined space-time 'distance' is calculated as 
%			sqrt( p*dx.^2 + (1-p)*dt.^2 ). 
%	     I.e. with 0 distance does not matter at all, while with
%	     1 time does not matter at all. (default = 0.5 = 50/50
%	     between km/days.)  
%
% dx       = MxN matrix of distances between the M main positions and
%            the N other positions.
% dt       = matrix of time differences in the same format as dx.
% I        = subscripts to the rows of dx and dt for differences
%            inside the limits set by mdx and mdt, i.e. which main
%            positions has 'near neighbours' in the other positions.
% J        = subscripts to the columns of dx and dt for differences
%            inside the limits set by mdx and mdt, i.e. which of the
%            other positions are the 'near neigbours'.
% JJ       = Mx1 cell with groups of indices to other positions
%            nearby, for each main position. Will be empty when no
%            near neighbours are found. 
%
% The subscripts are sorted by 'nearness' to each main position.
% JJ=J(ismember(I,27)) returns indices for the other positions near
% enough to the 27th main position, sorted with the nearest first. So
% for [LONG(27),LAT(27),T(27)], the nearest neighbours are
% [long(JJ,lat(JJ),t(JJ)]. For your convenience this is utilised in the
% making of output JJ, so that each cell in JJ contains the neighbours
% of each main position, so that the distance to the nearest neighbour
% of main profile 27 is dx(27,JJ{27}(1)), and likewise for dt. 
%
% A 3D plot of all points and connections is made if no output is
% requested.
%
% This function requires the SEAWATER toolbox.
%
% See also SW_DIST IND2SUB SALINITY_OFFSET

% Last updated: Mon May 15 15:15:25 2023 by jan.even.oeie.nilsen@hi.no

error(nargchk(5,9,nargin));
LONG=LONG(:); LAT=LAT(:); m=length(LONG); % main positions
long=long(:); lat=lat(:); n=length(long); % other positions
if nargin<9 | isempty(p), p=0.5; end
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
[~,II]=sort(sqrt((p*dx(JI)).^2+((1-p)*dt(JI)).^2)); % Sort the index after by 'distance' 
JI=JI(II);
[I,J]=ind2sub(size(dx),JI);	% Subscripts to the float-pos vs refdata-pos matrix:
for i=1:m 
  JJ{i,1}=J(ismember(I,i));	% Groups of indices to other
                                % positions, for each main position 
end


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
  for i=1:m
    if any(JJ{i})
      line([long(JJ{i}(1)) LONG(i)],[lat(JJ{i}(1)) LAT(i)],[t(JJ{i}(1)) T(i)],'color','g');
      line(long(JJ{i}(1)),lat(JJ{i}(1)),t(JJ{i}(1)),'marker','o','linestyle','none','color','r');
    end
  end
end
