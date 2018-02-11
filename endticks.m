function h=endticks(x1,x2,y1,y2,a)
% ENDTICKS      Special tickmarks at ends of axes
%
% h = endticks(x1,x2,y1,y2,a)
% 
% x1,.. = strings for the corners 'xmin' 'xmax' 'ymin' and 'ymax',
%         respectively. Use empty where no extra tickmark is desired.
% a     = handle of axes to operate on
%
% h     = vector of handles to the added text objects
%
% You might have to adjust the axes' limits or ticks to avoid strings
% overlapping existing tickmarks.

if nargin<5 | isempty(a),       a=gca;  end
if nargin<4 | isempty(y2),      y2='';  end
if nargin<3 | isempty(y1),      y1='';  end
if nargin<2 | isempty(x2),      x2='';  end
if nargin<1 | isempty(x1),      x1='';  end

% get original values
xl=get(a,'xlim'); xt=get(a,'xtick'); xb=cellstr(get(a,'xticklabel'));
yl=get(a,'ylim'); yt=get(a,'ytick'); yb=cellstr(get(a,'yticklabel'));

% change tick and ticklabel values
if ~isempty(xt)
  if ~isempty(x1)
    if xt(1)==xl(1),				xb(1)={x1};
    else			xt=[xl(1) xt];	xb={x1,xb{:}};	
    end
  end
  if ~isempty(x2)
    if xt(end)==xl(2),				xb(end)={x2};
    else			xt=[xt xl(2)];	xb={xb{:},x2};	
    end
  end
end
if ~isempty(yt)
  if ~isempty(y1)
    if yt(1)==yl(1),				yb(1)={y1};
    else			yt=[yl(1) yt];	yb={y1,yb{:}};	
    end
  end
  if ~isempty(y2)
    if yt(end)==yl(2),				yb(end)={y2};
    else			yt=[yt yl(2)];	yb={yb{:},y2};	
    end
  end
end

% set new values
set(a,'xtick',xt,'xticklabel',xb);
set(a,'ytick',yt,'yticklabel',yb);
