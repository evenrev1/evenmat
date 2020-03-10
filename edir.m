function files = edir(maindir,extension,mindepth,keepfile,newfiles)
% EDIR	finds all specified files in a directory and subdirectories.
% 
% files = edir(maindir,extension,mindepth,keepfile,newfiles)
% 
% maindir   = string of full path to the directory where sought files
%             and directories of such are located (no end slash). 
% extension = string of filename extension of specific files 
%             (e.g., nc).  Use * for any files.
% mindepth  = 
% keepfile  = logical on whether to keep the textfile of found paths.
% newfiles  = logical on whether to compare with old textfile of
%	      found paths and only output the new files. The textfile
%	      of paths will be expanded or remain complete.
%
% files     = cell array with full paths to each file.
% 
% This function utilizes the unix command FIND to recursively find
% files with regular expressions matching the given extension. It
% pipes the result to a file '..files.txt' in the current directory,
% (with name starting with the extension, e.g., ncfiles.txt), which
% is then read into matlab with TEXTREAD, resulting in the cell array.
%
% See also MKDIR DIR LS EMKDIR

if nargin<5|isempty(newfiles), newfiles=logical(0); else newfiles=logical(newfiles); end
if nargin<4|isempty(keepfile), keepfile=logical(0); else keepfile=logical(keepfile); end
if nargin<3|isempty(mindepth), mindepth=0; end
if nargin<2|isempty(extension), extension='*'; end
if nargin<1|isempty(maindir), maindir=pwd; end

if newfiles
  prev=textread([extension,'files.txt'],'%s');
else
  newfiles=logical(0);
end

%eval(['!find ',maindir,filesep,'* -regex ''.*.',extension,''' -mindepth 0 > ',extension,'files.txt'])
eval(['!find ',maindir,filesep,'* -regex ''.*.',extension,''' -mindepth ',int2str(mindepth),' > ',extension,'files.txt'])
files=textread([extension,'files.txt'],'%s','delimiter','');

if ~keepfile, delete([extension,'files.txt']); end

if newfiles,  files=setxor(prev,files); end


% maindir   = string of full path to the main directory where
%             directories of sought files are located (no end slash).
