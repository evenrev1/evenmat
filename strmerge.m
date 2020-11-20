function str = strmerge(str1,str2,delimiter,word1,word2,keepword)
% STRMERGE	Joins two strings at their common part, or specified
% words.
%
% str = strmerge(str1,str2,delimiter,word1,word2,keepword);
%
% STRMERGE will separate strings into 'words' defined by the input
% delimiter and then find the common 'word' and merge strings at that
% 'word'. 
% 
% str1      = string that will form the start of the output string.
% str2      = string that will form the end of the output string.
% delimiter = string used to separate the parts of the strings to
%             compare, and to merge the output (default=' ').
% word1     = string in str1 to join strings at instead of a common part. 
% word2     = string in str2 to join strings at instead of a common part.
% keepword  = numeric 1 or 2 for which word1/word2 to put at the
%             'joint' in the output (default = 1). 
%
% str       = cellstr of the merged input strings.
%
% This function is especially useful for changing paths to another
% location in directory tree.  Here is an example where the first part
% of a path is changed, conserving the subdirectories in the latter
% part:
%	str1='/Volumes/aremotedisk/temp/'
%	str2='~/Downloads/adirectory/temp/anotherdirectory/afile.txt'
%	strmerge(str1,str2,'/')
%
% See also STRCAT STRSPLIT JOIN

error(nargchk(2,6,nargin));
if nargin<6 | isempty(keepword),	keepword=1;	end
if nargin<5 | isempty(word2),		word2='';	end
if nargin<4 | isempty(word1),		word1='';	end
if nargin<3 | isempty(delimiter),	delimiter=' ';	end

ss1=strsplit(str1,delimiter);	% Split first string
ss2=strsplit(str2,delimiter);	% Split second string

if isempty(word1) | isempty(word2)
  [c,ia,ib]=intersect(ss1,ss2);	% Find common part
  if isempty(c)
    ss1,ss2, error('No overlapping part found between these!'); 
  else
    str=char(join([ss1(1:ia(end)-1) ss2(ib(end):end)],delimiter)); % merge
  end
else
  i1=find(contains(ss1,word1)); i2=find(contains(ss2,word2));
  if isempty(i1)
    ss1, error(['The string ''',word1,''' is not found in this first input string!']);
  elseif isempty(i2)
    ss2, error(['The string ''',word2,''' is not found in this second input string!']);
  else
    switch keepword
     case 1, str=join([ss1(1:i1),ss2(i2+1:end)],filesep);
     case 2, str=join([ss1(1:i1-1),ss2(i2:end)],filesep);
    end
  end
end

