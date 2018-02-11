function out=colwise(x,op,y)
% COLWISE       Columnwise arithmetic operation
% where a vector is interpreted as a column. Any operation can be done
% (see ARITH and 'help +'). 
%
% out=colwise(x,op,y)
%
% x   = matrix of size MxN
% y   = vector of length M (but no specific orientation, Mx1 or 1xM)
% op  = character of numerical operator
%       (without the . for '*','/','^','\')
%
% All columns of matrix are multiplied (as an example) element-by-element
% with the vector. In different words, all elements of the matrix' i-th
% _row_ are multiplied with the i-th element of the vector.
%
%       [11 12 13  * [a   =  [11*a 12*a 13*a 
%        21 22 23]    b]      21*b 22*b 23*b]
%
% can be achieved with                            COLWISE(x,'*',y)
%
% For row-wise operation, transposing x and transposing the answer back
% again, does the trick, but the length of the vector must then be the same
% as the number of columns in original matrix, and the result must be
% transposed back again. An operation like 
%
%       [11 12 13  * [a b c]  =  [11*a 12*b 13*c
%        21 22 23]                21*a 22*b 23*c]
%
% can be achieved with                            COLWISE(x','*',y)'
%
% See also ROWWISE ARITH (as well as 'HELP *')
 
%Time-stamp:<Last updated on 02/06/12 at 19:39:39 by even@gfi.uib.no>
%File:<~/matlab/colwise.m>

[mx,nx]=size(x);
[my,ny]=size(y);

% if mx==1 | (ny > 1 & my > 1)
%   error('Incorrect input format!')
% end

[X,Y]=meshgrid(x(1,:),y);

%if findstr(op,'*') | findstr(op,'/') | findstr(op,'^') | findstr(op,'\')
if op=='*' | op=='/' | op=='^' | op=='\'
  %[X,Y]=meshgrid(x(1,:),y);
  eval([ 'out=x.',op,'Y;' ]);
else
  %[X,Y]=meshgrid(x(1,:),y);
  eval([ 'out=x',op,'Y;' ]);
end



