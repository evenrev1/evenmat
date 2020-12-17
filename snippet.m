function s=snippet(x,filename,opt)
% SNIPPET	Prints object content as string to file.
%
% Transforms any input to strings and lists them with commas and/or
% 'and' dependent on the length of the input. Also writes result to a
% file of same name as input variable name (or a chosen filename), in
% order to include the content in documentation (e.g., using LaTeX \input).
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
%
% s.       = The resulting string, as is also written to file
%
% See also MAT2TAB STRING

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

s=string(x);

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
if contains(opt,'_'),findstr(s,'_'); s(ans)='-';end
if contains(opt,' '),findstr(s,' '); s(ans)='';end

fprintf(fid,s,'%s');
fclose(fid);
