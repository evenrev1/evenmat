function [gv,gi,gs]=groups(x,slim)
% GROUPS        identifies sequences of equal numbers in a vector
% ignoring single occurences of numbers
% 
% [gv,gi,gs] = groups(x,slim)
%
% x     = data-vector ínput
% slim  = size limit (lower) of what is considered groups (default=2).
%
% gv    = group-vector of size(x), containing numbers where the groups
%         are, and zeros elsewhere. The numbers 1,2,... identifies the
%         group number.
% gi    = a 2xn matrix with start and end indices for each group as
%         columns. 
% gs    = string listing the pairs of indices.
%         
% Example:              x  = [7 4 3 3 5 5 5 1 9 9] 
%                   =>  gv = [0 0 1 1 2 2 2 0 3 3]
%                       gi = [3  5  9;
%                             4  7 10]
%                       gs = '3-4, 5-7, and 9-10'
%
% Note that no sorting is performed, only groupings already present in x are
% detected. And single numbers do not constitute groups.
%
% NOTE: Could be expanded to be used for the equations on p.635 in Press,
% the general Spearman Rank Correlation.
%
% See also FIND SNIPPET ZIPNUMSTR

% Last updated: Wed Oct 25 07:35:37 2023 by jan.even.oeie.nilsen@hi.no

error(nargchk(1,2,nargin));
if nargin<2 | isempty(slim), slim=2; end

gv=zeros(size(x));			% Initialise the group-vector
%gv=nans(size(x));			% Initialise the group-vector
equalsm=find(~diff(x));			% Find all groups of equals (-last value)
if ~isempty(equalsm)			% Skip if no groups
  starts=[1;find(diff(equalsm(:))>slim-1)+1];% Find startpoints in equalsm
  nog=length(starts);			% number of groups
  for i=1:nog-1				
    g1=equalsm(starts(i));
    g2=equalsm(starts(i+1)-1)+1;
    gv(g1:g2)=repmat(i,1,length(g1:g2));
  end
  g1=equalsm(starts(end));
  g2=equalsm(end)+1;
  gv(g1:g2)=repmat(nog,1,length(g1:g2));
end

if isvec(x)==1, gv=gv(:); end	% shape gv according to x

if any(gv)
  % Make the index matrix:
  %find(logical(gv) & (diff([gv,NaN])~=0 | diff([NaN,gv])~=0));
  find(logical(gv) & (diff(cat(isvec(gv),gv,NaN))~=0 | diff(cat(isvec(gv),NaN,gv))~=0));
  gi=reshape(ans,2,length(ans)/2);
  % Make the text string:
  gs=string(gi)';
  size(gs,1); 
  gs=[gs(:,1),repmat("-",ans,1),gs(:,2),repmat(", ",ans,1)];
  if ans>1, gs(end-1,end)=", and "; end
  gs(end)="";
  gs'; 
  gs=sprintf('%s',ans(:)');
else
  gi=[];
  gs='';
end

% Remove the comma if there is only two groups (e.g., '1-3, and 7-9'):
if length(findstr(gs,','))<2 
  gs=replace(gs,{','},{''});
end
