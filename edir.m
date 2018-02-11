function files = edir(maindir,extension,keepfile)
% EDIR	finds all files in a directory and subdirectories
% 
% files = edir(maindir,extension,keepfile)
% 
% maindir   = string of full path to the main directory where sought
%             files are located (no end slash).
% extension = string of filename extension of specific files 
%             (e.g., nc).  Use * for any files.
% keepfile  = logical on whether to keep the textfile of found paths.
%
% files     = cell array with full paths to each file.
% 
% This function utilizes the unix command FIND to recursively find
% files with regular expressions matching the given extension. It
% pipes the result to a file '..files.txt' in the main directory,
% (with name starting with the extension, e.g., ncfiles.txt), which
% is then read into matlab with TEXTREAD, resulting in the cell array.
%
% See also MKDIR DIR LS EMKDIR

if nargin<3, keepfile=logical(0); end

%cd(maindir)
%pwd
%!find * -regex '.*.nc' -mindepth 1 > files.txt
%eval(['!find * -regex ''.*.',extension,''' -mindepth 1 > ',extension,'files.txt'])
eval(['!find ',maindir,filesep,'* -regex ''.*.',extension,''' -mindepth 1 > ',extension,'files.txt'])
files=textread([extension,'files.txt'],'%s');
if ~keepfile, delete([extension,'files.txt']); end
