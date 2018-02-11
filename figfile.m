function figfile(varargin)
% FIGFILE       printing function for FIG-figures
% Prints named figure(s) to eps-file(s) with same name(s), or to
% printer. If no name is given, current figure is printed to a file named 
% after current figure's nametag. 
%
% Added png option since eps is crap now on my machine.
%
% figfile(varargin)
%
% NAMES OF FIGURES to print may be input as separate strings and/or
%               cellstring arrays. Cellstring arrays might be useful when
%               automizing printing in a script, and separate string input
%               is handy when printing selected figures from command line,
%               but they can be mixed. Wildcards (*) may be used, and '*'
%               alone prints all open figures. 
%
% OPTIONS       string input starting with a '-' (minus) followed by any
%               of the following characters:
%               
%			'G' - png-format (dpng)
%			'k' - b/w eps-format (deps2)
%                       'g' - colormap gray and brighten(.5)
%                       's' - figstamp on figure
%                       'n' - figstamp w/name on figure
%                       'p' - to paper
%			'F' - PaperPosition full page
%			'L' - PaperOrientation landscape
%			'P' - PaperOrientation portrait
%
%		Furthermore printername can be specified in separate
%		string input starting with '>'.
%
% EXAMPLES      Command line no bracket syntax:
%                       FIGFILE afigure anotherfigure anuglyfigure      
%               With options 'to paper' and 'gray' on printer named 'hp4':
%                       FIGFILE -pg >hp4 afigure anotherfigure anuglyfigure
%               With cellstring object:
%                       myfigs={'afigure','anotherfigure','anuglyfigure'};
%                       FIGFILE(myfigs);
%                       FIGFILE('-pg',myfigs);
%               Print all open figures named 'an...':
%                       FIGFILE an*
%
% See also PRINT FIG FIGSTAMP

name=[]; newstamp=[];

% INPUT CHECK
%if ~any(get(0,'children')), error('No figures to print!'); end
if length(get(0,'children'))<1, error('No figures to print!'); end
for i=1:length(varargin)                
  varargin{i};
  if isnumeric(ans) 
    error('String, character and cellstring input only!');
  else
    cellstr(ans);                         % order all inputs into 
    name=[name;ans(:)];                   % one Nx1 cellstring array
  end
end

o=strmatch('-',name);                   % find any option strings and 
char(name(o));ans(:)';opt=char(ans);    % concatenate them into one string
name(o)='';                             % remove the entries with options

printer='';
p=strmatch('>',name);                   % find any printer strings and 
char(name(p));ans(:)';
printer=char(ans(2:end));		% concatenate them into one string
name(p)='';                             % remove the entries with options

% FIND NAMES FROM OPEN FIGURES
if nargin==0 | isempty(name)            % if no names given
  name=cellstr(get(gcf,'name'));        %   get current figure's nametag
else                                    % if any wildcards given
  name=wildcards(name);                 %   replace them with their matches
end

extension='.eps'; % default

% PROCESS NAMES and OPTIONS
for i=1:length(name),                   % one by one
  %if findobj('name',char(name(i)))      % if figure exist
  if ~isempty(findobj('name',char(name(i))))      % if figure exist
    fig(name(i));                       % make current and execute options:
    if findstr(opt,'G') | any(findstr(get(gcf,'tag'),'black'))
      format='png'; extension='.png';
    elseif findstr(opt,'k') | any(findstr(get(gcf,'tag'),'black'))
      format='eps2'; 
    else 
      format='epsc2';
    end
    if findstr(opt,'L')			% landscape
      set(gcf,'PaperOrientation','landscape');
    elseif findstr(opt,'P')		% portrait
      set(gcf,'paperorientation','portrait');
    end
    if findstr(opt,'F')			% fill paper
      if findstr(get(gcf,'paperorientation'),'landscape');
	set(gcf,'paperposition',[0.63452 0.63452 28.408 19.715]);
      else
	set(gcf,'paperposition',[0.63452 0.63452 19.715 28.408]);
      end
    end
    if findstr(opt,'g') 
      colormap gray; brighten(.5);      % gray and brighten
    end
    if findstr(opt,'n')			% put on figstamp (with name also)
      newstamp=figstamp([],name{i});
    elseif findstr(opt,'s')             % put on figstamp (with date)
      newstamp=figstamp;
    end 
    if findstr(opt,'p')                 % print to PAPER
      if isempty(printer)
	print -dpsc2  % For Unix/Linux
      % print -dwinc % for MS-Windows
      else
	eval(['print -dpsc2 -P',printer]);
      end	
      fprintf('Printed figure ''%s'' \n',char(name(i)));
    else				% or FILE
      oldstamp=findobj(get(gcf,'children'),'Tag','figstamp');
      %if any(oldstamp)&~any(newstamp), delete(oldstamp); end
      %if any(oldstamp)&any(newstamp), delete(oldstamp); end
      if ~isempty(oldstamp)&~isempty(newstamp), delete(oldstamp); end
      filename=[blankreplace(char(name(i))),extension];
      %eval(['print -d',format,' ',filename]);
      set(gcf,'paperpositionmode','auto')
      eval(['print -d',format,' -loose ',filename]);
      fprintf('Wrote file %s \n',filename);
    end
  else
    fprintf('Nonexisting figure ''%s'' !\n',char(name(i)));
  end
end

% for adding tiff preview:
% print -depsc -tiff -r300
%-----------------------------------------------
function name=wildcards(name)
name=cellstr(name);
get(0,'children'); allnames=get(ans,'name');
ni=[];
for i=1:length(name)            % loop through all input names
  nam=name{i};
  findstr(nam,'*');
  if ans                                % if wildcard
    ni=[ni,i];                          %   record which name it's in
    if ~isempty(allnames)               % if any open figures (robust test)
      allnames=cellstr(allnames);
      common=nam(1:ans-1);              %   find part before * and it's
      name=[name;allnames(strmatch(common,allnames))]; % matching figures
    end
  end
end
name(ni)='';                    % remove the entries with wildcards

