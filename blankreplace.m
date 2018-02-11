function s=blankreplace(s,sign)
% BLANKREPLACE  replace all blanks in string
%
% s = blankreplace(s,sign)
%
% s     = string
% sign  = a single character to replace the blanks with (default='_')
%
% Handy when trying to make filenames out of strings with blanks in.
%
% See also DEBLANK

error(nargchk(1,2,nargin));
if nargin<2 | isempty(sign),    sign='_';       end

s(findstr(s,char(32)))=sign;

