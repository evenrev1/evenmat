function [P,H] = ejoin(P1,P2)
% EJOIN	Join two polygons at their nearest points
% 
% [P,H] = ejoin(P1,P2)
% 
% P1,P2	= polygon coordinates in Mx2 matrices with x in first column
%         and y in second column (e.g., Vertices of pathch objects).
%
% P	= the joined polygon in the same manner.
% H	= If given, the joined patch is plotted and H is its handle.
%
% Example: 
% Make two dummy polygons with start/end at opposing sides
% axis;
% [P1(:,1),P1(:,2)]=ginput;patch(P1(:,1),P1(:,2),'g');
% [P2(:,1),P2(:,2)]=ginput;patch(P2(:,1),P2(:,2),'y');
% [P,H]=ejoin(P1,P2);
%
% See also PDIST2

%h(1)=patch(P1(:,1),P1(:,2),'g');h(2)=patch(P2(:,1),P2(:,2),'y');set(h(1),'edgecolor','g');set(h(2),'edgecolor','y');

distances = pdist2([P1(:,1),P1(:,2)],[P2(:,1),P2(:,2)]);% Find the closest two points of two patches
[~,mini] = min(distances(:));				% find index to the minimum value of distance
[mini,minj]=ind2sub(size(distances),mini);		% make subscripts (i.e., index for each)

%h(3)=line([P1(mini,1),P2(minj,1)],[P1(mini,2),P2(minj,2)],'marker','o','color','b'); 

P1(:,1)=P1([mini:end 1:mini-1],1); P1(:,2)=P1([mini:end 1:mini-1],2);	% Reorganise them so they start at those points
P2(:,1)=P2([minj:end 1:minj-1],1); P2(:,2)=P2([minj:end 1:minj-1],2);
P(:,1)=[P1(:,1);P2(:,1)]; P(:,2)=[P1(:,2);P2(:,2)];			% Join them

[~,I]=min(P(:,2)); P=P([I:end 1:I-1],:); % Reorganise the resulting to start at 'lowest' coordinate

if nargout>1
  H=patch(P(:,1),P(:,2),'b'); set(H,'facecolor','none','edgecolor','r','linestyle','--');
  line(P(1,1),P(1,2),'marker','*','color','r');
  legend('Joined polygon','Its first coordinate'); 
end




