function [d,y,cday]=yrday(t)
% YRDAY		Day of year
%
% [d,y,cday] = yrday(t)
%
% t	= serial days or complex yeardays (see below) 
%
% d	= decimal day of year (1-365)
% y	= year (YYYY) if serial days are input
% cday  = complex yeardays (see below)
%
% Uses datevec and datenum to calculate years and beginning of years,
% so leap years are accounted for. Note that there is no zero day,
% Jan 1 is day 1.
%
% Complex yeardays or circular year is a concept that removes the
% trouble when change of year may split a group of days into two groups
% of low and high values, similar to the challenges with degrees for
% direction. Here the yeardays are treated as degrees on a unit circle
% of 0-366 degrees and transformed to complex numbers.
%
% Conversion back to yeardays is done by input of complex yeardays.
% 
% See also DATEVEC DATENUM MONTH

D=size(t);

if ~isreal(t)
  d=angle(t)*366/2/pi;	% Transform back to days
  %d<0; if any(ans), d(ans)=d(ans)+366; end
  y=[];
else
  [y,d]=deal(nans(D));

  i=find(~isnan(t));

  [y(i),ans]=datevec(t(i));
  d(i)=t(i)-datenum(y(i),1,1,0,0,0)+1;
end

% Circular year:
phi=2*pi/366*d;
cday=complex(cos(phi),sin(phi));

