function b=stackaxes(sep,a,ax)
% STACKAXES	Stack axes in figure
% to get same gaps between axes after resizing or if just closer spacing
% is desired. Axes are stacked in the order of the input handle vector.
%
% b = stackaxes(sep,a,ax)
%
% sep	= Desired separation between axes in normalized units 
%			(default = 0.05)
% a	= Vector of handles to the group of axes to stack
%			(default = all axes in current figure)
% ax	= Direction to stack in, 'x' or 'y' (default)
%
% b	= Vector of handles to the axes 
%         sorted by their sequence in the figure 
%
% See also HOMAX SUBPLOT SUBLAY MULTILABEL PLOTMARK SORTAXESHANDLES

if nargin<3|isempty(ax),	ax='y';				end
if nargin<2|isempty(a),		autoax=1;
				a=get(gcf,'children');
				a=findobj(a,'visible','on',...
					  'type','axes');
				a=setdiff(a,findobj(a,'tag','legend'));
else				autoax=0;
end
if nargin<1|isempty(sep),	sep=.05;			end

if length(a)<2, 
  disp('It''s no use stacking just one set of axes. No action.');
  return; 
end

% stack the plots (in the order of input a, beginning at bottom)
get(a,'parent');par=[ans{:}];
figs=get(0,'children');
for j=1:length(figs)	% loop figures
  find(par==figs(j));
  b=a(ans);
  A=length(b);
  if A>1,
    switch ax
     case 'y'
      if autoax, b=sortaxeshandles(b,'y'); end
      pos=get(b,'position');
      cat(1,pos{:}); xp=min(ans(:,1));
      set(b(A),'position',[xp pos{A}(2:4)]);	% plasser nederste først
      for ii=1:A-1			% A-ii => begynner loop NEST nederst
	pos=get(b,'position');
	set(b(A-ii),'position',[xp ...		% felles xpos
		    pos{A-ii+1}(2)+...		% ypos = unders ypos
		    pos{A-ii+1}(4)+...		%      +  -"-   ysize
		    sep ...			%      + separator
		    pos{A-ii}(3:4)]);		% beholder størrelse 
      end
%                   pos{A-ii}(1) ...		% beholder sin xpos
     case 'x'
      if autoax, b=sortaxeshandles(b,'x'); end  % sorts left to right!
      pos=get(b,'position');
      cat(1,pos{:}); yp=min(ans(:,2));
      set(b(1),'position',[pos{1}(1) yp pos{1}(3:4)]);	% plasser venstre først
      for ii=2:A			%   ii => begynner 2 fra venstre
	pos=get(b,'position');
	set(b(ii),'position',[pos{ii-1}(1)+...	% xpos = venstres xpos
		    pos{ii-1}(3)+...		%      +   -"-    xsize
		    sep ...			%      + separator
		    yp ...			% felles ypos
		    pos{ii}(3:4)]);		% beholder størrelse 
      end
%		    pos{ii}(2) ...		% beholder sin ypos
    end
  end
end
