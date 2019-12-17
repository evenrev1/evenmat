function Y=dyear(n);
% DYEAR		Decimal year from julian day
%
% Y = dyear(n)
% 
% n	= serial (Julian) days where 1 corresponds to 1-Jan-0000
% Y	= Decimal year of the form 1969.89...
%
% Takes into consideration the actual length of each year, by
% adding the fraction of days into the year by the number of days in
% that year.
% 
% Note that this is not very useful in general. If you want to know
% the date and time you still would have to use DATENUM etc. because
% of leap years.
%
% See also YEARDAY DATEVEC DATENUM DATESTR DATENUM2 DATESTR2

% To test you can do something like this:
% datestr(time(1:10)), dyear(time(1:10)); datestr(datenum(ans,1,1)) 

mn=size(n);

n=n(:)';

[Y,M,D,h,m,s]=datevec(n); 

% Add the fraction (how many days into that year) / (days in that year)
(datenum(Y,M,D,h,m,s)-uplus(datenum(Y,1,1))) ./ (datenum(Y+1,1,1)-uplus(datenum(Y,1,1)));

Y = Y + uplus(ans);

Y=reshape(Y,mn);




% The old routine, very rough cut:
% [Y,M,D,h,m,s]=datevec(n);
% Y + uplus((M-1)/12) +  uplus(D/diff([datenum([Y;Y+1],1,1,0,0,0)]));
% Y=ans;

