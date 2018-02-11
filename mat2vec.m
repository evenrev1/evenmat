function x=mat2vec(X);
% MAT2VEC       transforms position matrices to vectors
%
% x = mat2vec(X);
%
% X	= input "position matrix", a matrix which is uniform in one
%         dimension, like the result of a [X,Y]=MESHGRID(x,y) on vectors
%         x and y.
% x	= output vector along the dimension of changing values in X.
% 
% For robustness, non-matrix inputs are sendt through unchanged.
%
% See also MESHGRID ISMAT

if ~ismat(X), 
  x=X; 
else
  dx=any(diff(X(1,:)));
  dy=any(diff(X(:,1)));
  if dx & ~dy
    x=X(1,:);
  elseif ~dx & dy
    x=X(:,1);
  else
    error('Input matrix is not uniform in any dimension!');
  end
end
