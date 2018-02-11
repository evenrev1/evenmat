function answer=isinteger(varargin)
% ISINTEGER     integer object test
% Returns a vector of logicals (1/0), true for the input objects containing
% only integers, and false for the others.
%
% answer = isinteger(varargin)
%
% See also ISREAL ISNUMERIC

%Time-stamp:<Last updated on 01/07/01 at 19:53:21 by even@gfi.uib.no>
%File:<d:/home/matlab/isinteger.m>

for i=1:length(varargin) 
  varargin{i};
  if isempty(ans), 
    answer(i) = 0;
  else 
    answer(i) = all(all(all(ans==round(ans))));
  end
end
