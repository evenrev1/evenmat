function answer=isint(varargin)
% ISINT         integer object test
% Returns a vector of logicals (1/0), true for the input objects containing
% only integers, and false for the others.
%
% answer = isint(varargin)
%
% See also ISREAL ISNUMERIC ISVEC

%Time-stamp:<Last updated on 06/04/24 at 11:51:54 by even@nersc.no>
%File:</home/even/matlab/evenmat/isint.m>

for i=1:length(varargin) 
  varargin{i};
  if isempty(ans), 
    answer(i) = 0;
  else 
    answer(i) = all(all(all(ans==round(ans))));
  end
end
