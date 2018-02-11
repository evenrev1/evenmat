function [r,y,i]=rang(x,opt)
% RANG          rank of data (rang in norwegian = rank)
%
% [r,y,i] = rang(x,opt)
%
% x     = vector data sample 
% opt   = options       1) Resolve "ties" by assigning average rank to
%                          equal datavalues (default)
%                       0) Don't resolve ties
%
% r     = the rank table, a vector corresponding to x, with the
%         data-values replaced by their rank among the other values in x.
% y     = the order statistics of the sample x (the sorted vector).
% i     = the index table, a vector corresponding to y, showing the
%         sorted values' original position in the data-sample x.  
%         y = x(i)
%
% REFERENCES: Wilks p.23, 50-53 ; Press p.329-333 (section 8.4), 633
%
% See also SORT GROUPS 

error(nargchk(1,2,nargin));             % input check
if nargin<2 | isempty(opt), opt=1; end

[y,i]=sort(x);                          % sorting
r(i)=1:length(i);                       % assigning rank
if isvec(i)==1, r=r(:); end          % ensure shape-consistency

if opt==1                               % Resolve ties if requested:
  gv=groups(y);%                        % Find group-vector
  for j=1:max(gv)                       % Loop through each group
    i(find(gv==j));                     % index of equals (group)
    r(ans)=repmat(mean(r(ans)),size(ans)); % group-ranks = avg rank
  end
end
