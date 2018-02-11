function eload(varargin)
% ELOAD         load data saved by ESAVE
% 
% Additional options given separately:
%
%		-L	gives a LIST of available datafiles for the
%			(specified) directory.
%		-D	DELETE .mat file
%
% See ESAVE for documentation. Remember to customize in this file.
%
% See also ESAVE LOAD SAVE

%Time-stamp:<Last updated on 03/09/23 at 11:22:47 by even@gfi.uib.no>
%File:</home/janeven/matlab/evenmat/eload.m>

%%%%%%%%%%% CUSTOMIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%datadir='/home/mydata/data/matlab-data';  % The location of data
% Alternatively, use link at home (unix), i.e.
% ln -s /home/mydata/data data
datadir='~/data/matlab-data';
% HOW TO USE AN ENVIRONMENT VARIABLE HERE INSTEAD? i.e.
% setenv MATLABDATA "/local/mydata/data/matlab-data" in .cshrc
%datadir=$MATLABDATA % ???
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


li = strcmp(varargin,'-l') | strcmp(varargin,'-L') ;	% option LIST
list=any(li); if list,  varargin=varargin(~li); end  
de = strcmp(varargin,'-d') | strcmp(varargin,'-D') ;	% option DELETE
del=any(de);  if del,   varargin=varargin(~de); end  

if isempty(varargin),   file='matlab';                  % filename input
else                    file=varargin{1};               end

% more arguments input
if length(varargin)>1
  vars=cellstrcat(varargin(2:end),''''',''''');
else                    vars='';                        end

slashes = [findstr(file,'/') findstr(file,'\')]; % locate any slashes

file(slashes)='/';                      % flip slashes for compatibility

if any(slashes)                         % PATH given
  inpath = file(1:slashes(end)-1);      % Separate filename from given path  
  file   = file(slashes(end)+1:end);
  if ~any(findstr(inpath,':'))&~strcmp(inpath(1),'/') % PARTIAL PATH
    inpath=[pwd,'/',inpath];                          % build location with PWD
  end
else                                    % NO PATH given
  inpath = pwd;                         % location is PWD
end

colon=findstr(inpath,':');              
if any(colon)                           % PC ROOT in path
  inpath(colon)='';                     % remove the colon (retain drive letter)
elseif strcmp(inpath(1),'/')            % UNIX ROOT in path
  inpath(1)='';                         % remove the root-slash
end

loadfile=[datadir,filesep,inpath,filesep,file]; % make full loadpath and file
  
%['evalin(''caller'',''load(''''',loadfile,...          % test
%      ''''',''''',vars,''''')'')']
if del
  disp('Do You really want to delete MAT-file');
  disp([loadfile,'.mat?']);
  input('(y/n)','s');
  if strcmp(ans,'yes')|strcmp(ans,'y'), delete([loadfile,'.mat']); end
elseif list
  disp(['MAT-files stored in ',datadir,filesep,inpath,' :']); %disp(' ');
  ls([datadir,'/',inpath]);disp(ans);
else
  eval(['evalin(''caller'',''load(''''',loadfile,...      % The load
      ''''',''''',vars,''''')'')']);
end

