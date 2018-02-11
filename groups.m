function gv=groups(x)
% GROUPS        identifies sequences of equal numbers in a vector
%
% gv = groups(x)
%
% x     = data-vector
% gv    = group-vector ofsize(x), containing numbers where the groups
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
