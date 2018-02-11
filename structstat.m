function y = structstat(fun,x,field)
% STRUCTSTAT    Statistics on multidimensional structurals
% 
% y = structstat(fun,x,field)
% 
% fun  = string indicating what statistic to calculate:
%        'MEAN', 'SUM', 'MEDIAN', 'STD', 'MIN', or 'MAX'. 
% x     = the multidimensional structural containing the ...
% field = field to operate on (string naming the field).
%
% y     = The resulting array of same size as chosen field.
% 
% From an array of structurals (multidimensional structure), one of
% the abovementioned statistics of a specified structural field is
% calculated using the corresponding NAN-function (e.g. NANMEAN) if
% available. Can be handy for calculating overall statistics between
% output from BIN3D.
%
% EXAMPLE: If                     x(1).a = [1 2; 4 5]
%          and                    x(2).a = [3 6; 8 9]
%          then structstat('mean',x,'a') = [2 4; 6 7]
%
% See also NANMEAN STRUCT BIN3D

%Time-stamp:<Last updated on 06/04/20 at 14:33:08 by even@nersc.no>
%File:</Home/even/matlab/evenmat/structstat.m>

if isempty(x) % Check for empty input.
    y = NaN;
    return
end

D=size(getfield(x(1),field));

% reshape into array
%x={x(:).a};
eval(['x={x(:).',field,'};']);
n=length(D);
x=shiftdim(x,1-n); % n=4=>-3 % n=3=>-2 % n=2=>-1 % n=1=2 (2x1 og 1x2)
X=cell2mat(x);
X=shiftdim(X,n);  % n=4=>4  % n=3=>3  % n=2=>2  % n=1=2 (2x1 og 1x2)

try, y=feval(['nan',fun],X);
catch, y=feval(fun,X);
end

y=shiftdim(y,1);


