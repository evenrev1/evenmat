function md_file = m2md(m_file,md_file,opt)
% M2MD	Copies M-file to a Markdown (MD) version of itself.
% 
% Particularly useful if you want to use your Matlab Contents.m file as
% your README.md in github.
%
%	md_file = m2md(m_file,md_file,opt)
% 
% m_file     = Name of file to convert (default = 'Contents.m')
% md_file    = Name of the converted file (default = 'README.md'
%	       if both empty input, or <m_file>.md )
% opt	     = character object containing the options (default = 'b'):
%		'b' - Make bold any first word on a line that is
%		      followed by \t (tab).	
%
% - First line will be formatted with heading size font.
% - Start bulleted list with '- '. 
% - Instances of 'https://...' will result in links, but not in a
%   quote (tab in front). 
% - If you want file names to come out in bold, you must format those 
%   lines with '% '<file name>'\t'<description> as done in this file. 
%
% For MD-syntax, see https://docs.github.com/en/github/writing-on-github/ 
%
% See also REGEXP REGEXPREP FPRINTF

error(nargchk(0,3,nargin));
if nargin<3 | isempty(opt),	opt='b';		end
if (nargin<1 | isempty(m_file)) & (nargin<2 | isempty(md_file))	
  m_file=[pwd,filesep,'Contents.m'];
  md_file=[pwd,filesep,'README.md'];
elseif nargin<2 | isempty(md_file)
  r=regexp(m_file,'(\w*)\.m','tokens')
  md_file=regexprep(m_file,'(\w*)\.m',[r{1}{1},'.md'])
end

if ~exist(m_file,'file'), error([m_file,' does not exist!']); end

if contains(opt,'b'), boldfile=true; else, boldfile=false; end

% Skip overwrite-check, because resulting file is a copy anyway. (At
% least I never make MD-files of my own.)
% if exist(md_file,'file')
%   reply = input('File ',md_file,' exists! Overwrite? Y/N [Y]:','s');
%   if ~isempty(reply) | reply~='Y' 
%     return
%   end
% end

fin=fopen(m_file);
fout=fopen(md_file,'w');

fgetl(fin);
replace(ans,'%','#');		% First line as heading
fprintf(fout,'%s\n',ans);	% Add newline
while 1
  fgetl(fin);
  if ans==-1, break; end
  r=regexp(ans,'% (\S+)\t','tokens');	% file names in list
  if ~isempty(r) & boldfile
    regexprep(ans,'% (\S+)\t',['**',r{1}{1},'**\t'],'once');
  end
  regexprep(ans,'\t-',' -','once'); % Remove tabs when there's a list mark
  r=regexp(ans,'http(\S?)://(\S*)','match');	% insert links
  if ~isempty(r)
    regexprep(ans,'https://(\S+)',['[',r{1},']','(',r{1},')']);
  end
  replace(ans,'%','');			% Remove comment marking
  fprintf(fout,'%s\n',ans);		% Write with newline
end

fclose(fin);
fclose(fout);
