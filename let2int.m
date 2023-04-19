function I = let2int(s)
% LET2INT	letters' number in the alphapet
% Converts from character in the alphabet to integer number by the
% logic A=1, B=2, etc. Case is irrelevant.
% 
% I = let2int(s)
% 
% s   = character or string input containing A-Z. Other
%	characters will be ignored.
% 
% I   = scalar or vector of integers representing the letters 
%	A-Z by 1-26.  
% 
% See also CHAR

I=double(upper(char(s)))-64;

I=I(1<=I & I<=26); % ASCII codes 65:90

