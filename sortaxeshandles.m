function b=sortaxeshandles(a,ax)
% SORTAXESHANDLES	Sorts handle vector on position
% 
% Takes all input axes handles, checks their axes' position (y), and
% sorts their handles from top to bottom or left to right.
% 
% b = sortaxeshandles(a)
%
% a	= input vector of handles (to axes)
% ax	= 'x' or 'y' (default)
%
% b	= sorted vector of handles to the axes
%
% See also STACKAXES HOMAX SUBPLOT SUBLAY MULTILABEL PLOTMARK 

if nargin<2|isempty(ax),	ax='y';				end
if nargin<1|isempty(a),		a=get(gcf,'children');		end
a=findobj(a,'type','axes');

%get(gcf,'children');
%b=ans(strcmp(get(ans,'type'),'axes'));
b=[];
while length(a)>1			% LOOP as while picking 
%for i=1:length(a)
  get(a,'position');
  pp=cat(1,ans{:});
  switch ax
   case 'y'
    p=pp(:,2);%+uplus(pp(:,2));		
    [ans,minxi]=sort(p);			% the one with highest position
   case 'x'
    p=pp(:,1);%+uplus(pp(:,2));		
    [ans,minxi]=sort(p);			% the one with highest position
    minxi=flipud(minxi);
  end
  b=[b a(minxi(end))];		% add (smallest) handle to output
  a=a(setdiff(1:length(a),minxi(end)));	% remove handle from input
end
b=[b a];		% add the last
%b=fliplr(b(:)');	% reverse order (