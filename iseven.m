function a=iseven(x);
% ISEVEN	Even or odd number?
%
% x	= any vector, matrix, or array
%
% a	= corresponding object with 1 for even numbers and 0 elsewhere
%
% Non numeric inputs gives nan input.
%
% "ISODD" = ~ISEVEN
%
% See also ISNUMERIC

a=logical(round(x/2)==x/2);

%a(~isnumeric(x))=nan;
