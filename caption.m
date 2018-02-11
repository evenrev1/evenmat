function h=caption(string,hght)
% CAPTION       adds a caption under axis
%
% h=caption(string,hght)
%
% string = caption text
% hght   = height of caption in pixels (may have to be adjusted for long
%          captions. Have not gotten around to automize this.)
%
% See also LEGEND UICONTROL

%Time-stamp:<Last updated on 00/06/30 at 14:35:49 by even@gfi.uib.no>
%File:<d:/home/matlab/caption.m>

error(nargchk(1,2,nargin));
if nargin<2 | isempty(height)
  hght=50;
end
ch=get(gcf,'children');
li=strcmp(get(ch,'type'),'uicontrol');
ai=strcmp(get(ch,'type'),'axes');
tag=get(ch(li),'tag');
if tag & strmatch(tag,'caption')
  h=ch(li);
  set(h,'string',string);
else
  % set page layout (paper) to fill A4-page
%  if findstr(get(gcf,'paperorientation'),'landscape');
 %   set(gcf,'paperposition',[0.63452 0.63452 28.408 19.715]);
 % else
 %   set(gcf,'paperposition',[0.63452 0.63452 19.715 28.408]);
 % end
  set(gcf,'units','pixels');
%  keyboard
  ax=ch(ai);
  if length(ax)>1
    error('Function not expanded for multiaxis figures!');
  end
  set(ax,'units','pixels');
  ap=get(ax,'position');
  %  for i=1:length(ax)
  %    p=ap{i};
  %     set(ax(i),'position',[p(1) p(2)+hght p(3) p(4)]);
  %  end
  get(gcf,'position');
  set(gcf,'position',[ans(1) ans(2)-hght ans(3) ans(4)+hght]);
  set(ax,'position',[ap(1) ap(2)+hght ap(3) ap(4)]);
  Pos=[ap(1) 2 ap(3) hght-5];
  
  h=uicontrol('style','text','backgroundcolor','w',...
      'string',string,'HorizontalAlignment','left',...
      'Units','pixels','position',Pos,...
      'tag','caption');
  
  set(ax,'units','normalized');
end




