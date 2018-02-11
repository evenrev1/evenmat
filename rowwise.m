function out=rowwise(x,op,y)
% ROWWISE       row-wise arithmetic operation
% where a vector is interpreted as a row (more info in COLWISE).
%
% out=rowwise(x,op,y)
%
% x   = matrix of size MxN
% y   = vector of length N (but no specific orientation, Nx1 or 1xN)
% op  = character of numerical operator
%       (without the . for '*','/','^','\')
%
% See also COLWISE ARITH (as well as 'HELP *')

%Time-stamp:<Last updated on 01/09/18 at 23:29:26 by even@gfi.uib.no>
%File:<d:/home/matlab/rowwise.m>

out=colwise(x',op,y)';
