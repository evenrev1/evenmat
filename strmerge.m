function str = strmerge(str1,str2,delimiter)
% JOINSTR	Joins two strings at their common part. Especially
% useful for changing paths to another location in directory tree.   
%
% str = strmerge(str1,str2,delimiter);
%
% STRMERGE will separate strings into 'words' defined by the input
% delimiter and then find the common 'word' and merge strings at that
% 'word'. 
% 
% str1      = string that will form the start of the output string.
% str2      = string that will form the end of the output string.
% delimiter = string used to separate the parts of the strings to
%             compare (default=' ').
% 
% Example where the first part of a path is changed, conserving the
% subdirectories in the latter part:
%	str1='/Volumes/aremotedisk/temp/'
%	str2='~/Downloads/adirectory/temp/anotherdirectory/afile.txt'
%	strmerge(str1,str2,'/')
%
% See also STRCAT STRSPLIT JOIN

error(nargchk(2,3,nargin));
if nargin<3 | isempty(delimiter), delimiter=' '; end

ss1=strsplit(str1,delimiter);	% Split first string
ss2=strsplit(str2,delimiter);	% Split second string
[c,ia,ib]=intersect(ss1,ss2);	% Find common part
if isempty(c)
  ss1,ss2, error('No overlapping part found between these!'); 
else
  str=char(join([ss1(1:ia(end)-1) ss2(ib(end):end)],delimiter)); % merge
end
