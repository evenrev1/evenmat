function [gv,gi,gs]=groups(x)
% GROUPS        identifies sequences of equal numbers in a vector
%
% [gv,gi,gs] = groups(x)
%
% x     = data-vector
% gv    = group-vector of size(x), containing numbers where the groups
%         are, and zeros elsewhere. The numbers 1,2,... identifies the
%         group number.
%         
% Example:              x  = [7 4 3 3 5 5 5 1 9 9] 
%                   =>  gv = [0 0 1 1 2 2 2 0 3 3]
%
% PS! No sorting is performed, only already present groupings in x are
% detected.

% NOTE: Could be expanded to be used for the equations on p.635 in Press,
% the general Spearman Rank Correlation.
%
% See also FIND SNIPPET ZIPNUMSTR

gv=zeros(size(x));		% Initialise the group-vector
%gv=nans(size(x));		% Initialise the group-vector
equalsm=find(~diff(x));         % Find all groups of equals (-last value)
if ~isempty(equalsm)		% Skip if no groups
  starts=[1;find(diff(equalsm(:))>1)+1];% Find startpoints in equalsm
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
  find(logical(gv) & (diff([gv,NaN])~=0 | diff([NaN,gv])~=0));
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
