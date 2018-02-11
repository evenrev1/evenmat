function ii=findi(varargin)
ii=[]; jj=1:length(varargin{1});
for k=1:2:length(varargin)	% loop through each data/searchvector-pair
  x=varargin{k}; numbers=varargin{k+1};
  for i=1:length(numbers)	% loop through each number in searchvector
    ii=[ii;find(x(jj)==numbers(i))];
  end
  jj=ii;
end
