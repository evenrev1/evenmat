function esave(varargin)
% ESAVE         save into data directory
%
% ESAVE works just like SAVE, but puts the datafiles into a designated
% data-directory, so that your home- and working directories (and their
% backups) does not get filled up by datafiles. ELOAD is the parallel
% function for loading. 
%
% The two functions ESAVE and ELOAD should to the eye work exactly like
% their sister functions, SAVE and LOAD. 
%
% Keeping track of the files is done by mimicking the directory structure
% you work in (full path), recursively in the data-directory. Any file, even
% the many matlab.mat files will be kept apart in different directories.
%
% Example: Calling ESAVE while working in the directory "D:/home/work/"
% results in a save to "D:/data/matlab-data/d/home/work/matlab.mat". Note
% the use of drive-letter in the data-directory structure. You will not
% notice this however, since calling ELOAD in the same working directory,
% will fetch the data (just as easy as LOAD does when SAVE is used). Any
% other specification of savepath and filename, will also work. ESAVE finds
% out where you want it, but uses the mirror-directories instead.
%
% The advantage of this is that although matlab binary-data (.mat) is fast
% to use, one probably has the original data in a safe place to begin with,
% so there is no need for backing up the .mat files, and less need for
% filling up the home-disk with these files. Assumed of course, that you
% keep the matlab-routines for reading and analyzing the data in matlab, so
% that you easily can remake the .mat files from the original data. For
% unique and original .mat-files, please use the good old SAVE so that the
% data is saved locally, and have a fair chance of being backed up.
%
% CUSTOMIZATION: The path to the directory under wich you want the matlab
% binaries' directories, has to be edited in both ESAVE.M and ELOAD.M just
% below the help section.
%
% COMPATIBILITY: Made on a PC, but I tried to make it compatible with unix
% as well.
%
% See also ELOAD SAVE LOAD

%Time-stamp:<Last updated on 03/09/23 at 11:22:47 by even@gfi.uib.no>
%File:</home/janeven/matlab/evenmat/esave.m>

%%%%%%%%%%% CUSTOMIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%datadir='/home/mydata/data/matlab-data';  % The location of data
% Alternatively, use link at home (unix), i.e.
% ln -s /home/mydata/data data
datadir='~/data/matlab-data';
% HOW TO USE AN ENVIRONMENT VARIABLE HERE INSTEAD, i.e.
% setenv MATLABDATA "/local/mydata/data/matlab-data" in .cshrc
%datadir=$MATLABDATA % ???
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% filename input
if isempty(varargin),   file='matlab';                  
else                    file=varargin{1};               end
% more arguments input
if length(varargin)>1,  vars=cellstrcat(varargin(2:end),''''',''''');
else                    vars='';                        end

slashes = [findstr(file,'/') findstr(file,'\')];% locate any slashes
file(slashes)='/';                    % flip slashes for compatibility

if any(slashes)                       % PATH given
  inpath = file(1:slashes(end)-1);    % Separate filename from given path  
  file   = file(slashes(end)+1:end);
  if ~any(findstr(inpath,':'))&~strcmp(inpath(1),'/') % PARTIAL PATH
    inpath=[pwd,'/',inpath];                          % build location with PWD
  end
else                                  % NO PATH given
  inpath = pwd;                       % location is PWD
end

colon=findstr(inpath,':');              
if any(colon)                         % PC ROOT in path
  inpath(colon)='';                   % remove the colon (retain drive letter)
elseif strcmp(inpath(1),'/')          % UNIX ROOT in path
  inpath(1)='';                       % remove the root-slash
end

savefile=[datadir,filesep,inpath,filesep,file]; % make full savepath

emkdir(datadir,inpath);

%['evalin(''caller'',''save(''''',savefile,...          % test
%      ''''',''''',vars,''''')'')']
eval(['evalin(''caller'',''save(''''',savefile,...      % The save
      ''''',''''',vars,''''')'')']);


