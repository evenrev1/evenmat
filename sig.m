function h=sig(signature)
% SIG           signature by axis of 2D-plot
% Adds a signature at the bottom right side of current axis.
% 
% h = sig(signature)
%
% signature = string with name (default must be edited in code)
%
% See also FIGSTAMP

%Time-stamp:<Last updated on 04/12/08 at 11:31:46 by even@nersc.no>
%File:</home/even/matlab/evenmat/sig.m>

%%%%%% CUSTOMIZATION: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mysig='J. Even Ø. Nilsen ';%,date] ;
mysig=['Nilsen ',datestr(now,10)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

error(nargchk(0,1,nargin));
if nargin<1 | isempty(signature) | ~ischar(signature)
  signature = mysig;
end

oldsig=findobj(get(gca,'children'),'Tag','sig');

if ~any(oldsig)
  %  ax=rightmostaxis; axes(ax);
  axis; x=ans(2); y=ans(3);
  horal='left';
  veral='top';
  rotat=90;
  
  h=text(x,y,signature);
  set(h,'FontSize',10,'Units','pixels',...
        'FontAngle','italic',...
        'HorizontalAlignment',horal,'VerticalAlignment',veral,...
        'Rotation',rotat,...
        'Clipping','off',...
	'Tag','sig');
  %   set(gcf,'tag',strcat(ftag,'sig'));
end

%------------------------------------------
function ax=rightmostaxis()
get(gcf,'children');
ax=ans(strcmp(get(ans,'type'),'axes'));
get(ax,'position');
pp=cat(1,ans{:});
[ans,maxx]=sort(pp(:,1));
ax=ax(maxx(end));

