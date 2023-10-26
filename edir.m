function [files,names] = edir(maindir,extension,mindepth,keepfile,newfiles)
% EDIR	finds all specified files in a directory and its subdirectories.
% 
% [files,names] = edir(maindir,extension,mindepth,keepfile,newfiles)
% 
% maindir   = string of full path to the directory where sought files
%             and directories of such are located (no end slash). 
%             (default=PWD). 
% extension = string of filename extension of specific files 
%             (e.g., 'nc'). (Default= '*' for any files.)
% mindepth  = Mindepth argument for find to use. 
%             (default=0). 
% keepfile  = logical on whether to keep the textfile of found paths
%             (default=0). 
% newfiles  = logical on whether to compare with old textfile of
%	      found paths and only output the new files. The textfile
%	      of paths will be expanded or remain complete.
%             (default=0). 
%
% files     = cell array with full paths to each file.
% names	    = cell array with just the names of each file.
% 
% This function utilizes the unix command FIND to recursively find
% files with regular expressions matching the given extension. It
% pipes the result to a file '..files.txt' in the current directory,
% (with name starting with the extension, e.g., ncfiles.txt), which
% is then read into matlab with TEXTREAD, resulting in the cell array.
%
% See also MKDIR DIR LS EMKDIR

% Last updated: Thu Oct 26 15:13:45 2023 by jan.even.oeie.nilsen@hi.no

if nargin<5|isempty(newfiles), newfiles=logical(0); else newfiles=logical(newfiles); end
if nargin<4|isempty(keepfile), keepfile=logical(0); else keepfile=logical(keepfile); end
if nargin<3|isempty(mindepth), mindepth=0; end
if nargin<2|isempty(extension), extension='*'; end
if nargin<1|isempty(maindir), maindir=pwd; end

if keepfile | newfiles % In the rare occasion when someone wants to use the
            % file or compare to previous finds, they will have to be
            % on MacOS/Unix/Linux so that edir can use the shell command find:
  
  if newfiles
    prev=textread([extension,'files.txt'],'%s');
  else
    newfiles=logical(0);
  end
  
  %eval(['!find ',maindir,filesep,'* -regex ''.*.',extension,''' -mindepth 0 > ',extension,'files.txt'])
  %eval(['!find ',maindir,filesep,'* -regex ''.*.',extension,''' -mindepth ',int2str(mindepth),' > ',extension,'files.txt'])
  eval(['!find ',' ',maindir,filesep,'*',' -mindepth ',int2str(mindepth),' -regex ''.*.',extension,'''',' > ',extension,'files.txt'])
  
  try files=textread([extension,'files.txt'],'%s','delimiter','');
    
    if nargout==2
      F=textread([extension,'files.txt'],'%s','delimiter',filesep);
      f=contains(F,['.',extension]);
      names=F(f);
    end

    if ~keepfile, delete([extension,'files.txt']); end
    
    if newfiles,  files=setxor(prev,files); end
    
  catch 
    files=''; names='';
  end

else % Use the purely Matlab based version
  
  extension=replace(extension,'*','');		% Remove the asterisk as it is superfuous in this case
  d=dir([maindir,filesep,'**/*',extension]);	% Use deep searching dir
  files=strcat({d.folder}',filesep,{d.name}');	% Merge the outputs to cell list with full paths
  names={d.name}';				% Get list of names
  ~contains(files,[filesep,'.']);		% Remove '.', '..', etc. directories from the list
  files=files(ans); names=names(ans);

end
  
  
