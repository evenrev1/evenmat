function crop(m,a)
% CROP		Crop figure to axis
%
% crop(m,a)
%
% m	= Margins in pixels [left x, bottom y, right x, top y] or single
%	  number for all margins equal (default = 0)
% a	= handle to axes to crop around (default = current axes)
%
% Some times printing to file leaves whitespace around a plot. To remove
% this, CROP wraps the figure (window) as tightly as you wish around the
% chosen axes without changing the size of the axes. The choice of margins
% is a matter of trial and error. Printing will only print what's inside the
% figure (window), so the problem should be solved. 
%
% Resize figure window before using crop, if you wish to do so. (Resizing
% window seems to affect the print resolution with jpeg.)
%
% Both figure and axes are left with 'Units' set to 'pixels', they have
% to to be printed properly.
%
% TIPS: Always crop before changing paperposition of figure.
%
% See also FIG FIGFILE HOMAX STACKAXES SUBPLOT SUBLAY MULTILABEL PLOTMARK

error(nargchk(0,2,nargin));
if nargin<2|isempty(a),		a=get(gcf,'children');
				a=findobj(a,...%'visible','on',...
					  'type','axes');
				a=setdiff(a,findobj(a,'tag','legend'));
end
if nargin<1|isempty(m),	m=0;	end

%if any(findstr(get(gcf,'tag'),'crop')), return; end

if issingle(m),	     m=repmat(m,1,4);
elseif length(m)~=4, error('Margin input must be single or 4 element!');
end

f=get(a(1),'parent');				% get the figure handle

au=get(a(1),'units');
fu=get(f,'units');

set([a(:);f],'units','pixels');			% measure both in pixels

N=length(a);

if N<2
  ap=get(a,'Position');				% get original positions
  fp=get(f,'Position'); 
  set(f,'position',[fp(1:2) ap(3:4)+m(1:2)+m(3:4)]);% figure
  set(a,'position',[m(1:2) ap(3:4)]);			    % axes	
else
  aap=axpos(a);
  ap=get(a,'Position');				% get original positions
  fp=get(f,'Position'); 
  set(f,'position',[fp(1:2) aap(3:4)+m(1:2)+m(3:4)]); % figure
  for i=1:N
    set(a(i),'position',ap{i}+[-aap(1:2)+m(1:2) 0 0]);	% axes
  end
end
  
set(a,'units',au);	% No! Don't set units back to other than pixels
set(f,'units',fu);	% Something goes wrong then when printing

addtag('crop',gcf);
