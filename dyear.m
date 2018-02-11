function Y=dyear(n);
% DYEAR		Decimal year from julian day
%
% Y = dyear(n)
% 
% n	= serial (Julian) days where 1 corresponds to 1-Jan-0000
% Y	= Decimal year of the form 1969.89
%
% See also DATEVEC DATENUM DATESTR DATENUM2 DATESTR2

mn=size(n);

n=n(:)';

[Y,M,D]=datevec(n);

Y + uplus((M-1)/12) +  uplus(D/diff([datenum([Y;Y+1],1,1,0,0,0)]));

Y=ans;

Y=reshape(Y,mn);

