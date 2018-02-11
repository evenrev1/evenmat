function TF = between(A,x,B)
% BETWEEN	true for data within multiple intervals A-B. 
% I.e.  A(1)<=x & x<=B(1) & A(2)<=x & x<=B(2) & ... 
% This is useful for composite studies.
%
% TF = between(A,x,B)
% 
% A	= vectors with start points for wanted intervals.
% x	= vector of data to search in.
% B	= vectors with stop points for wanted intervals.
%
% All three inputs must have data in the same units (e.g. time in
% serial days).
%
% TF	= vector of the same size as x containing 1 where the
%	  elements of x are true values to the logical expression 
%         A(:) <= x <= B(:) using all elements in A and B.
% 
% See also OPS FIND

error(nargchk(3,3,nargin));
A=A(:); B=B(:);x=x(:);
N=length(A); M=length(x);
if N~=length(B), error('Inputs A and B must be vectors of same length!');end

TF=zeros(M,1);
for j=1:N
  [A(j) <= x & x <= B(j)];
  %TF=any([TF,ans],2);
  TF=TF+ans;
end
TF=logical(TF);

%j=cell2mat(j)';
%j=unique(j);
