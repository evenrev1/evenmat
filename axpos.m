function pos=axpos(a)
%
% See also HOMAX SUBPLOT SUBLAY MULTILABEL PLOTMARK SORTAXESHANDLES

if nargin<2|isempty(a),		a=get(gcf,'children');
				a=findobj(a,...%'visible','on',...
					  'type','axes');
				a=setdiff(a,findobj(a,'tag','legend'));
end

a=sortaxeshandles(a);		% sorts their handles from top to bottom.

p=get(a,'position');

if length(a)<2
  pos=p;
else
  cat(1,p{:}); 
  x1=min(ans(:,1));
  x2=max(ans(:,1)+ans(:,3));
  y1=min(ans(:,2));
  y2=max(ans(:,2)+ans(:,4));
  pos=[x1 y1 x2-x1 y2-y1];
  %pos=[p{end}(1:2) ans p{1}(2)+p{1}(4)];
end

