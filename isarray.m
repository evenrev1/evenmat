function answer=isarray(varargin)
% ISARRAY	array object test
% Returns a vector of logicals (1/0) for which input objects are
% arrays, and which are not (empty, single, vector and matrices). 
%
% answer = isarray(varargin)
% 
% See also ISVECTOR ISSINGLE ISMATRIX

%Time-stamp:<Last updated on 02/05/28 at 11:44:01 by even@gfi.uib.no>
%File:<d:/home/matlab/isarray.m>

for i=1:length(varargin)
  size(varargin{i});
  if length(ans)>2 & any(ans(3:end)>1)	% varargin{i} is an array
    answer(i)=1;			
  else
    answer(i)=0;
  end
end
answer=logical(answer);