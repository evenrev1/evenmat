function y=sigdig(x,n)
% SIGDIG	Change number of significant digits
%
% y = sigdig(x,n)
%
% x	= number(s) to be modified
% n	= single number of significant digits wanted in ...
%
% y	= the "rounded" output.
%
% This is a type of rounding where position of decimal point is
% irrelevant. The input is modified to have the given number of
% significant digits.
%			   sigdig(0.0982,2)	->  0.098
%			   sigdig(98265,3)	->  98300
%
% See also ROUND FIX FLOOR CEIL RES REM MOD 

%Time-stamp:<Last updated on 02/05/14 at 15:14:01 by even@gfi.uib.no>
%File:<d:/home/matlab/sigdig.m>

error(nargchk(2,2,nargin));

sx=num2str(x,n);
y=str2num(sx);
