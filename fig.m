function h=fig(name,opt)
% FIG           figures identified by name instead of number
% Creates, or makes current, a figure with 'Title' and 'Tag' name.
% Using FIG with a name replaces using FIGURE with a number, but
% has special options for screen- and paper-sizing.
%
% h = fig(name,opt)
%
% name         = figure name string.
% opt          = string of the following option characters:
%                'k' - delete figure
%                'F' - PaperPosition full page
%                'L' - PaperOrientation landscape
%                'P' - PaperOrientation portrait
%                's' - manual sizing of figure on Screen
%                      (fullscreen figure-window is default)
% '1','2','3' or '4' - figure in one of the quadrants         1 _|_ 2
%                      Combinations like '12' for upper       3  |  4
%                      half of screen etc. is possible.
%                      These positioning arguments can
%                      also be given as numeric input.
%
% WHY NAMES...  It's a lot easier to keep track of figure names than
% numbers, especially when numbers might change from session to
% session. A figure will now have the same name no matter how many
% figures you already have made.
%
% A string as identifier also has the advantage that it can be be the
% same in all the environments where the figure might appear
% (figure-title in matlab = filename = figure-reference in LaTeX).
%
% It is generally not a good idea to have blanks in the name, although
% FIGFILE replaces them with underscores when printing to file. Then
% further references to this figure(file) must also use the
% underscores.
%
% SIZING: The Screen-sizing-related options, are only operational when
% when creating the figure (first time call), but the Paper-related
% arguments may be given to an existing figure.
%
% SIMPLE SYNTAX: Since this function has all-character-input, you can
% take advantage of matlab's no-brackets syntax: "fig salinity 2" will
% create a figure-window named 'salinity' in the upper right corner of
% screen.
%
% See also FIGFILE FIGURE

error(nargchk(0,2,nargin));
if nargin<2 | isempty(opt)
  opt='';                       % insert option letter for default
                                % figure-placement here
elseif isnumeric(opt)
  if opt>0 & opt<=4             % size-options 1-4
    opt=char(48+round(opt));    % 48 is aciii number for 0 (zero)
  else                          % other size-options
    switch opt
     case 12, opt='12';
     case 34, opt='34';
     case 13, opt='13';
     case 24, opt='24';
    end
  end
end
opt=strcat('-',opt);% make sure opt is longer than any option

if     nargin < 1 | isempty(name), h=figure;            return;
elseif isnumeric(name),            h=figure(name);      return;
else
  name=char(name);
  number=findobj('name',name);  %tag
end

if findstr(opt,'k') & number
  delete(number); return
end

if ~isempty(number)          % If figure-window exists, make it current
  h=figure(number);          % Beware! handle 'number' might be on
                             % something else than a figure (Ouch!).
                             % or several figures can have same name,
                             % like '' (no name)
elseif findstr(opt,'s')  % manual sizing
%  h=figure('Tag',name,'name',name);
  h=figure('name',name);
  disp('Resize figure, then press enter!'); pause
else
  % choice of one of four quadrants or fullscreen
  set(0,'units','pixels');
  %get(0,'screensize');
  %[1 1 1437 942]; 
  %[0 70 1920 1200]; 
  %[0 70 1300 1200];
  get(0,'MonitorPositions'); % ans(ans(:,1)==1,:)+[0 70 0 0];
  ox=ans(1); oy=ans(2); w=ans(3); h=ans(4);
  %ox=ans(1); oy=ans(2); w=ans(3)-ox; h=ans(4)-oy;
  %x=ceil(w/2)+5; y=ceil(h/2)+2; ww=x-6; wh=y-50;
  x=ceil(w/2)+ox; y=ceil(h/2)+oy; ww=x-ox; wh=y-oy-35;
  if     findstr(opt,'12'), screen = [ox , y, 2*ww,   wh]; % upper
  elseif findstr(opt,'34'), screen = [ox , oy, 2*ww,   wh]; % lower
  elseif findstr(opt,'13'), screen = [ox , oy,   ww, h-68]; % left
  elseif findstr(opt,'24'), screen = [x , oy,   ww, h-68]; % right
  elseif findstr(opt,'1'),  screen = [ox , y,   ww,   wh];
  elseif findstr(opt,'2'),  screen = [x , y,   ww,   wh];
  elseif findstr(opt,'3'),  screen = [ox , oy,   ww,   wh];
  elseif findstr(opt,'4'),  screen = [x , oy,   ww,   wh];
  else                      screen = [ox , oy,   w,  h]; % full
  end
  %  h=figure('Tag',name,'name',name,'position',screen);
  %h=figure('name',name,'position',screen);
  h=figure('name',name);
end

% get rid of the menues and toolbar
%set(h,'windowstyle','modal')
% No!" Comment in order to fix the issue of locking window shifting (was 'modal')


% paper-settings (may be given at a later call to existing figure):
set(gcf,'paperunits','centimeters');
if findstr(opt,'L')     % landscape
  set(gcf,'paperorientation','landscape');
elseif findstr(opt,'P') % portrait
  set(gcf,'paperorientation','portrait');
end
if findstr(opt,'F')     % fill paper
  if findstr(get(gcf,'paperorientation'),'landscape');
    set(gcf,'paperposition',[0.63452 0.63452 28.408 19.715]);
  else
    set(gcf,'paperposition',[0.63452 0.63452 19.715 28.408]);
  end
end

%set(h,'windowstyle','normal');
