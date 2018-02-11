function [X,YYYY] = ymshape(x,t,startmonth,yearmonth)
% YMSHAPE	reshaping year and month into separate array dimensions
% Reshapes a monthly timeseries array into array with years running
% down columns, and the 12 months of the year in an extra last
% dimension. Has also the ability to shift the year to other months
% for practical purposes (see below). 
% The reverse reshaping is also possible. 
%
% [X,YYYY] = ymshape(x,t,startmonth,yearmonth)
% 
% x          = data array with time (monthly) as 1st dimension
% t          = Numeric  : Time vector in serial days (if omitted,
%                         monthly counting from day 1, "year 0").
%              Character: Instead of separating months (forward
%                         operation), the months are stacked (back)
%                         onto eachother in the columns (the time
%                         dimension). Input x then does not need to
%                         have all 12 months (e.g. just some winter
%                         months). 
%
% startmonth = month of year to start new year-structure in. Handy
%              for e.g. regressions, since  winter signals are
%              usually stronger. 
%              (default=1, January)
% yearmonth  = month of year defining the year of the new structure.
%              A "year" starting in July 1998 could be dubbed 1998 or
%              1999, as in "the winter of 1999"  (default=1, January).
%              
% X          = the reshaped array, with years as 1st dimension, and 
%	       month-of-year as last dimension. Alternatively, for
%	       'reverse' reshaping, all time (consequtive months) in
%	       1st dimension. 
% YYYY       = the corresponding year-vector.
%
% See also RESHAPE PERMUTE

%Time-stamp:<Last updated on 08/10/14 at 17:58:33 by even@nersc.no>
%File:</Users/even/matlab/evenmat/ymshape.m>
%startmonth=7; yearmonth=6; 
error(nargchk(1,4,nargin));
S=size(x);
if nargin<4 | isempty(startmonth),	startmonth=1;	end
if nargin<3 | isempty(yearmonth),	yearmonth=1;	end
if nargin<2 | isempty(t),		t=datenum(0,1:S(1),1); end
sm=startmonth;
ym=yearmonth;

if ~ischar(t) % ---forward (separate years and months) --
  
if S(1)+sm-1<12, error(['Cannot separate months and years without 12 or' ...
		   ' more months in timeseries!']); end

  [yy,mm]=datevec(t); % make months
  t=datenum(yy,mm,1); % Round to whole months
    
  % CHANGE SEASON:
  find(mm==sm);is=ans(1);
  yrs=floor((S(1)-is+1)/12);
  ii=is-1+[1:yrs*12];
  t=t(ii);
  
  [yy,mm]=datevec(t); 
  T=t(mm==ym);
%  T=t([1:12:end]+12+ym-sm); % serial days for the year-vector
  [YYYY,ans]=datevec(T); 	  % year-vector 
  range=datestr(t([1 end])),	%test
  %datestr(T([1 end])),		%test
  years=YYYY([1 end])		%test

  X=cutmat(x,ii,1);	% select the chosen months in data

  S=size(X);		% the new size

  % RESHAPE TO SEPARATE YEARS AND MONTHS:
  P=12; Q=S(1)/P; D=length(S);          %P,Q,D
  X=shiftdim(X,1);			%size(X)
  X=reshape(X,[S(2:end) P Q]);		%size(X)
  X=shiftdim(X,D);			%size(X)
  %permute(X,[D:-1:1]);			size(X)
  %X=reshape(X,[fliplr(S(2:end)) P Q]);	size(X)
  %X=permute(X,[D+1 D-1:-1:1 D]);	size(X)
      
else % ---reverse (stack the input month-array) -------

  D=length(S);
  X=shiftdim(x,D-1);			%size(X)
  M=S(1)*S(end);
  X=reshape(X,[M S(2:end-1)]);		%size(X)


end
