function [y,d]=yearday(t)
% YEARDAY	Day of year
%
% [y,d]=yearday(t)
%
% t	= serial day
%
% y	= year (YYYY)
% d	= decimal day of year (1-365)
%
% See also DATEVEC DATENUM MONTH

D=size(t);

[y,d]=deal(nans(D));

i=find(~isnan(t));

[y(i),ans]=datevec(t(i));
d(i)=t(i)-datenum(y(i),1,1,0,0,0);

