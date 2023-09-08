function s = snippet(x,filename,opt,conj,groupfields,Nstr,ext)
% SNIPPET	Prints object content as string to file.
% Transforms any input to strings and lists them with commas and
% 'and' dependent on the length of the input. Also writes result to a
% file of same name as input variable name (or a chosen filename), in
% order to include the content in documentation (e.g., using LaTeX
% \input{}). 
% 
% s = snippet(x,filename,opt,conj,groupfields,Nstr,ext)
% 
% x           = any variable (possibly)
% filename    = Optional file name. Particularly useful when input is
%               indexed or not a named object. (default='snippet.tex')
%               Input of ';' supresses writing to file. 
% opt         = Optional string of one or more characters to replace, as these
%               might cause trouble in LaTeX or other places. The list of
%               available characters and their replacements are:
%               '_' -> '-' (underscore is often problematic)
%	        ' ' -> ''  (removal of all spaces)
%               'deblank' -> Removes trailing blanks
% conj        = conjunction to use to join last two parts (default = ', and ').
%
% For struct input:
% groupfields = Cell array of names of fields in input struct to
%	        sum up contents using GROUPS instead of listing all
%	        numbers (default = {''}).
% Nstr	      = Max length to show for long vector fields (default = 50).
% ext         = file name extension, replcing the default 'tex'.
% 
% s           = The resulting string, as is also written to file.
%
% Input of a structure results in multiline output and file, in the
% same style as is echoed when stucture name is entered on command
% line. This is useful when putting, e.g., configuration parameters in
% a report. 
%
% For sorted and compact output (e.g., '1-3, 5, 7-9, and 11'), use
% ZIPNUMSTR on your numeric vector before input here.
%
% See also MAT2TAB STRING DEBLANK ZIPNUMSTR GROUPS

% Last updated: Fri Aug 11 11:22:48 2023 by jan.even.oeie.nilsen@hi.no

error(nargchk(1,7,nargin));
if nargin <7 | isempty(ext),		ext='tex';		end
if nargin <6 | isempty(Nstr),		Nstr=50;		end
if nargin <5 | isempty(groupfields),	groupfields={''};	end
if nargin <4 | isempty(conj),		conj=', and ';		end
if nargin <3 | isempty(opt),		opt='';			end
if nargin <2 | isempty(filename)
  if isempty(inputname(1))
    filename=['snippet.',ext];
  else
    filename=[inputname(1),'.',ext];
  end
elseif ~strcmp(filename,';')
  filename=[filename,'.',ext];
end

if ~strcmp(filename,';')
  fid=fopen(filename,'w');
end

if isstruct(x) % Special code for multiline output of fields in structures
  fnam=fieldnames(x);
  ss=char(strcat(pad(fnam,'left'),{': '}));
  for i=1:length(fnam)
    y=getfield(x,fnam{i});
    w=whos('y');
    if isnumeric(y)
      if strcmp(fnam{i},groupfields)
	%[~,~,y]=groups(y);
	y=listnumstr(y,[],conj);
      elseif any(w.size>Nstr,'all')
	y=['[',regexprep(int2str(w.size),'  ','x'),' ',w.class,']'];
      elseif all(w.size==0,'all')
	y='[]';
      else
	y=num2str(y);
      end
    end

    if exist('fid','var'), fprintf(fid,'%s%s\n',ss(i,:),y); end 
  end
  s=filename;
  % s=char(strcat(pad(fieldnames(x),'left'),{': '},struct2cell(x)));
  % for i=1:size(s,1)
  %   fprintf(fid,'%s\n',s(i,:)); 
  % end

else  % The original code to make small one line snippet

  s=string(x);
  if contains(opt,'deblank'),s=deblank(s);end

  n=length(s(:));
  if n>1
    s=[s(:),repmat(", ",length(s),1)];
    s(end)="";
    %s(end-1)=" and ";
    s(end-1)=string(replace(conj,{','},{''}));
  end
  if n>2
    %s(end-1)=", and ";
    s(end-1)=string(conj);
  end  
  s=s'; s=s(:);
 
  ss='';
  for i=1:length(s)
    ss=[ss,char(s(i))];
  end
  s=ss;

  % Optional replacements
  if contains(opt,'deblank'),s=deblank(s);end
  if contains(opt,'_'),findstr(s,'_'); s(ans)='-';end
  if contains(opt,' '),findstr(s,' '); s(ans)='';end

  if exist('fid','var'), fprintf(fid,s,'%s'); end % \n ?
end

if exist('fid','var'), fclose(fid); end

