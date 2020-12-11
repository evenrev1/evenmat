function s=snippet(x,filename)
% SNIPPET	Prints object content as string to file.
%
% Transforms any input to strings and lists them with commas and/or
% 'and' dependent on the length of the input. Also writes result to a
% file of same name as input variable name (or a chosen filename), in
% order to include the content in documentation (e.g., using LaTeX \input).
% 
% s = snippet(x,filename)
% 
% x        = any variable (possibly)
% filename = Optional file name. Particularly useful when input is
%            indexed or not a named object. (default='snippet.tex')
% 
% See also MAT2TAB STRING

error(nargchk(1,2,nargin));
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

fprintf(fid,s,'%s');
fclose(fid);
