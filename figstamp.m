function h=figstamp(signature,varargin)
% FIGSTAMP      signature- and info-stamp on figures
% Adds a signature and current date, as well as additional strings, at
% the bottom left of figure window  
% 
% h=figstamp(signature,varargin)
%
% signature = desired string, name etc. (default must be edited in code) 
% varargin  = strings to follow the signature in figure (filename etc.)
%
% h         = handle to the new or old stamp (text object)
%
% There will be a warning if there is already a stamp in the figure. This
% can be overridden by the input of the option string 'owerwrite'.
%
% See also TEXT

%Time-stamp:<Last updated on 14/10/10 at 10:09:34 by even@nersc.no>
%File:</Users/even/matlab/evenmat/figstamp.m>

%%%%%%%%%% CUSTOMIZATION  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
default_signature = [ 'Jan Even Nilsen ',date] ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

override=0; 

if nargin<2 | isempty(varargin)
  extra='';
else
  extra=char(32);
  for i=1:length(varargin), 
    if strmatch(varargin{i},'overwrite'), override=1;  
    else extra=[extra,char(32),varargin{i}]; 
    end
  end
end
if nargin<1 %| ~ischar(signature)
  signature = default_signature;
end
%  | isempty(signature) % let it be empty

%get(gcf,'position'); w=ans(3);

%ftag=get(gcf,'tag');
oldstamp=findobj(get(gcf,'children'),'Tag','figstamp');

if strcmp(signature,'off')	% special options
  if exist('oldstamp'), delete(oldstamp); end
  h=[];
elseif exist('oldstamp')
  if ~override
    ans=questdlg('Owerwrite the figstamp in this figure?',...
		 ['Figure ',get(gcf,'name'),' already stamped!'],...
		 'Overwrite','Cancel','Cancel');
    if strmatch(ans,'Overwrite')
      delete(oldstamp);
      h=stamp(signature,extra); 
    else
      h=oldstamp;
    end
  else
    delete(oldstamp);
    h=stamp(signature,extra);
  end
else
  h=stamp(signature,extra);
end






%------------------------------------------------------
function h=stamp(signature,extra)    
margin=20;
ax=findobj(get(gcf,'children'),'type','axes');
defunits=get(ax(1),'units');
set(ax,'units','pixels'); ppc=get(ax,'position');
set(ax,'units',defunits);
%get(ax,'position');
if iscell(ppc), ppm=cat(1,ppc{:});
else            ppm=ppc;                end
[ans,ii]=min(ppm(:,1)+uplus(ppm(:,2)));
pp=ppm(ii,1:2);

set(gcf,'currentaxes',ax(ii))
%    ax=lowerleftmostaxis;
%    defunits=get(ax,'units');
%    set(ax,'units','pixels'); pp=get(ax,'position');
%    set(ax,'units',defunits);
%    set(gcf,'currentaxes',ax);
    h=text(0,-pp(2)+margin,[signature,extra],...
           'FontSize',8,'FontAngle','italic', ...
           'HorizontalAlignment','left',...
           'verticalalignment','bottom', ...
           'rotation',0,...
           'Units','pixels',...
	   'Interpreter','none',...
           'Tag','figstamp');
    %  set(gcf,'tag',strcat(ftag,'stamped'));
%------------------------------------------------------
function ax=lowerleftmostaxis() % not in use
get(gcf,'children');
ax=ans(strcmp(get(ans,'type'),'axes'));
get(ax,'position');
pp=cat(1,ans{:});
p=pp(:,1)+uplus(pp(:,2));
[ans,minxi]=sort(p);
ax=ax(minxi(1));

