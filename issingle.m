function answer=issingle(varargin)
% ISSINGLE      single number object test
% Returns a vector of logicals (1/0) for which input objects are
% single numbers and which are not (empty, vector, arrays and matrices). 
% 
% answer=issingle(varargin)
%
% See also ISVECTOR ISMATRIX

%Time-stamp:<Last updated on 02/06/14 at 16:03:56 by even@gfi.uib.no>
%File:<d:/home/matlab/issingle.m>

for i=1:length(varargin)
  size(varargin{i});
  if isnumeric(varargin{i}) & length(ans)<=2 & all(ans==1)
    answer(i)=1;			% varargin{i} is a single number
  else
    answer(i)=0;
  end
end
answer=logical(answer);