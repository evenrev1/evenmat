function zs = zipnumstr(x,conj)
% ZIPNUMSTR	makes string summing up the numbers in a vector
% 
% zs = zipnumstr(x,conj)
% 
% x	= input integer vector.
% conj  = conjunction to use to join last two parts (default = ', and ').
%
% zs	= the combined string of numbers in x.
%
% EXAMPLE:
%	zipnumstr([1 1 1 2 3 5 7:9 11])
%	ans = '1-3, 5, 7-9, and 11'
% 
% See also SNIPPET MAT2TAB STRING DEBLANK GROUPS

error(nargchk(1,2,nargin));
if nargin<2 | isempty(conj), conj=', and '; end

y=unique(x(:))';
y=[y,y(end)+2]; % Add dummy at end to fool the loop below
zs='';
y1=y(1);
for i=2:length(y)
  if ~(y(i-1)==y(i) | y(i-1)==y(i)-1) % Not same or subsequent number 
    if ~isempty(zs) & i==length(y) & i==3,	zs=[zs,replace(conj,{','},{''})];
    elseif ~isempty(zs) & i==length(y),		zs=[zs,conj];
    elseif ~isempty(zs),			zs=[zs,', ']; 
    end
    y2=y(i-1);
    if y1==y2 
      zs=[zs,int2str(y1)];
      y1=y(i);
    else
      zs=[zs,int2str(y1),'-',int2str(y2)];
      y1=y(i);
    end
  end
end

% Remove the comma if there is only two groups (e.g., '1-3, and 7-9'):
if length(findstr(zs,','))<2 & any(findstr(conj,',')) & ~strcmp(strip(conj),',')
  zs=replace(zs,{','},{''});
end
