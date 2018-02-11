function [X,varargout]=rinsemat(X,varargin)
% RINSEMAT      strips a 2D matrix of all-NaN rows and columns 
% Vectors with ordinates corresponding to the matrix-rows and -columns
% will also be stripped. 
%
% [X,x,y] = rinsemat(X,x,y)
%
% X           = the matrix to be rinsed, and the one that govern the
%               rinsing of the other arguments.
% varargin    = vectors and matrices to be rinsed the same way as X.
%               Vectors with same length as the length of rows are taken to
%               correspond to the rows, and same for vectors corresponding
%               to columns. Only vectors that fit this, and matrices of
%               same size as X, will be processed (this ensures robustness). 
%
% varargout   = The rinsed objects in same order as input (including any
%               not rinsed objects).
%
% See also NAN

%Time-stamp:<Last updated on 06/09/14 at 11:31:49 by even@nersc.no>
%File:</home/even/matlab/evenmat/rinsemat.m>

[M,N]=size(X);
cols2keep=~all(isnan(X));		% find what to keep
rows2keep=~all(isnan(X'));

X=X(rows2keep,cols2keep);		% rinse X

% loop through the varargin
for i=1:length(varargin)
  x=varargin{i};
  if ismatrix(x) & size(x)==[M,N]
    x=x(rows2keep,cols2keep);		% rinse extra matrices
  elseif isvec(x)
    if	   mfind(length(x),N+[0:1])	% same length or one more*
      x=x(cols2keep);			% rinse x-vectors
    elseif mfind(length(x),M+[0:1])
      x=x(rows2keep);			% rinse y-vectors
    end
  end    
  varargout{i}=x;
end

% *: I have relaxed the restriction on same length for vectors, to
% include vectors with one extra element (like bin-lims).








