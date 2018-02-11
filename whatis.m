function answer=whatis(x)
% WHATIS        What kind of numeric object?
%
% answer = whatis(x)
%
% answer      = one of the following strings:
%               'notnumeric','scalar','column','row','matrix'
%
% See also ISNUMERIC ISSINGLE ISVECTOR ISMATRIX

if ~isnumeric(x),       answer='notnumeric';
elseif issingle(x),     answer='scalar';        
elseif isvec(x)==1,  answer='column';
elseif isvec(x)==2,  answer='row';
elseif ismatrix(x),     answer='matrix';
end
