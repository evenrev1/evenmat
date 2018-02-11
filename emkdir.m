function [status,msg] = emkdir(parentdir,dir)
% EMKDIR	Create directory structure 
% ignoring prior existence of some or all directories in the structure
%
% [status,msg] = emkdir(parentdir,dir)
%
% parentdir	= string for an existing directory under which to create
%		  the new directories. (default = pwd) 
% dir		= string of directory structure to create under 'parentdir'
%
% status,msg	= See MKDIR (status is here a vector for all subdirectories)
%
% Single input is interpreted to be 'dir', and parentdir will be the
% current directory.
%
% See also MKDIR ELOAD ESAVE

%Time-stamp:<Last updated on 02/06/04 at 13:09:41 by even@gfi.uib.no>
%File:<h:/matlab/emkdir.m>

error(nargchk(1,2,nargin));
if nargin<2 
  dir=parentdir;
  parentdir=pwd;
end

if parentdir==filesep, parentdir=''; end % in case you stand in root

% findstr(parentdir,filesep);	% Strip off leading and trailing filesep
% if any(ismember(length(parentdir),ans)),parentdir=parentdir(1:end-1); end
% if any(ismember(1,ans)),		parentdir=parentdir(2:end); end
jj=findstr(dir,filesep);
if any(ismember(length(dir),jj)),	dir=dir(1:end-1); end
if any(ismember(1,jj)),			dir=dir(2:end); end
jj=findstr(dir,filesep);
if isempty(jj),  jj=length(dir)+1; end

n=length(jj);

dirc{1}=dir(1:jj(1)-1);			% Separate into cellstring
for i=2:n
  dirc{i}=dir(jj(i-1)+1:jj(i)-1);
end
dirc{n+1}=dir(jj(end)+1:end);

for j=1:n+1				% Loop the cellstrings
  status(j)=mkdir(parentdir,dirc{j});
  parentdir=[parentdir,filesep,dirc{j}];
end



return
status=0;
while status~=1 | j<length(jj) % not success or not end
  status=mkdir(parentdir,dir(1:jj(j)-1)); % try one at a time
  %if status == 0 
    %case 0 % no success (assume two new directory-levels)
  %elseif jj(j)<=jj(end) % success but not last directory
    %case 1 % exists now	
    %case 2 % already exists	=>  try next if any
    parentdir=[parentdir,filesep,dirc(j)]
    dir=dir(jj(j)+1:end)
    j=j+1;
  %else  
  %end
end




