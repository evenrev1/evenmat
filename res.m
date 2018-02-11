function [d,w]=res(x)
% RES           find the decimals 
% the residual after removing the integer from a real number
%
% [d,w] = res(x);
%
% x	= input number or array
%
% d	= decimals/residual of that number
% w	= whole number, floor(x)
%
% See also MOD REM 

%Time-stamp:<Last updated on 02/05/14 at 13:12:39 by even@gfi.uib.no>
%File:<~/matlab/res.m>

w=floor(x);
d=x-w;
