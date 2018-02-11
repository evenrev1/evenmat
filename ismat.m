function answer=ismat(varargin)
% ISMAT      matrix object test
% Returns a vector of logicals (1/0) for which input objects are
% matrices, and which are not (empty, single, vector and arrays). 
%
% answer = ismat(varargin)
% 
% See also ISVEC ISSINGLE ISARRAY

for i=1:length(varargin)
  size(varargin{i});
  if length(ans)<=2 & all(ans>1)	% varargin{i} is a matrix
    answer(i)=1;			
  else
    answer(i)=0;
  end
end
answer=logical(answer);
