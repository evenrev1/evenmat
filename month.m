function s = month(i,dateform)
% MONTH	String of month from month number (1-12)
% 
% s = month(i,dateform)
%
% i	    = Number indicating which month you want the name (1 - 12)
% dateform  = number giving the format according to the table in DATESTR
%             (default = 3: Jan, Feb, ...) 
% s	    = Short name of month in a string
% 
% See also MONTHAXIS DATESTR YEARDAY

error(nargchk(1,2,nargin));
if nargin<2 | isempty(dateform), dateform=3; end

s=datestr(10+(i-1)*30,dateform);
