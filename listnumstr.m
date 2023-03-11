function lns = listnumstr(x,omit,conj,sep)
% LISTNUMSTR	makes string listing positions of numbers in vector 
% I.e. gives a string with summaries of indices for different numbers
% that exists in the vector, in the sequence they first appear.
% The inices are grouped and groups separated by semicolons.
%
% lns = listnumstr(x,omit,conj,sep)
% 
% x    = input integer vector.
% omit = vector of numbers to omit (e.g. [0])
% conj = conj to use to join last two parts of each 
%        groupstring (default = ', and '). 
% sep  = string separating each groupstring (default = '; ').
%
% lns  = the combined string of positions of numbers in x.
%
% EXAMPLE:
%	listnumstr([7 4 3 3 5 5 5 1 9 9])
%	ans = '1; 2; 3-4; 5-7; 8; 9-10'
% 
% See also ZIPNUMSTR SNIPPET MAT2TAB STRING DEBLANK GROUPS

error(nargchk(1,4,nargin));
if nargin<4 | isempty(sep),	sep='; ';	end
if nargin<3 | isempty(conj),	conj=', and ';	end
if nargin<2 | isempty(omit),	omit=[];	end

if isempty(x), lns=''; return; end

y=setdiff(x,omit,'stable');
lns='';
for i=1:length(y)
  lns=[lns,sep,zipnumstr(find(x==y(i)),conj)]; 
end
lns=lns(length(sep)+1:end);

