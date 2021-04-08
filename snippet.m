function s=snippet(x,filename,opt)
% SNIPPET	Prints object content as string to file.
%
% Transforms any input to strings and lists them with commas and/or
% 'and' dependent on the length of the input. Also writes result to a
% file of same name as input variable name (or a chosen filename), in
% order to include the content in documentation (e.g., using LaTeX
% \input{}). 
% 
% s = snippet(x,filename,opt)
% 
% x        = any variable (possibly)
% filename = Optional file name. Particularly useful when input is
%            indexed or not a named object. (default='snippet.tex')
% opt      = Optional string of one or more characters to replace, as these
%            might cause trouble in LaTeX or other places. The list of
%            available characters and their replacements are:
%            '_' -> '-' (underscore is often problematic)
%	     ' ' -> ''  (removal of all spaces)
%            'deblank' -> Removes trailing blanks
% 
% s        = The resulting string, as is also written to file.
%
% Input of a structure results in multiline output and file, in the
% same style as is echoed when stucture name is entered on command
% line. This is useful when putting, e.g., configuration parameters in
% a report.
%
% See also MAT2TAB STRING DEBLANK 

error(nargchk(1,3,nargin));
if nargin <3 | isempty(opt), opt=''; end
if nargin <2 | isempty(filename)
  if isempty(inputname(1))
    filename=['snippet.tex'];
  else
    filename=[inputname(1),'.tex'];
  end
else
  filename=[filename,'.tex'];
end

fid=fopen(filename,'w');

if isstruct(x) % Special code for multiline output of fields in structures
  fnam=fieldnames(x);
  ss=char(strcat(pad(fnam,'left'),{': '}));
  for i=1:length(fnam)
    y=getfield(x,fnam{i});
    w=whos('y');
    if isnumeric(y)
      if any(w.size>1,'all')
	y=['[',regexprep(int2str(w.size),'  ','x'),' ',w.class,']'];
      elseif all(w.size==0,'all')
	y='[]';
      else
	y=num2str(y);
      end
    end
    fprintf(fid,'%s%s\n',ss(i,:),y); 
  end
  s=filename;
  % s=char(strcat(pad(fieldnames(x),'left'),{': '},struct2cell(x)));
  % for i=1:size(s,1)
  %   fprintf(fid,'%s\n',s(i,:)); 
  % end

else % The original code to make small one line snippet

  s=string(x);
  if contains(opt,'deblank'),s=deblank(s);end

  n=length(s(:));
  if n>1
    s=[s(:),repmat(", ",length(s),1)];
    s(end)="";
    s(end-1)=" and ";
  end
  if n>2
    s(end-1)=", and ";
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

  fprintf(fid,s,'%s'); % \n ?
end

fclose(fid);
