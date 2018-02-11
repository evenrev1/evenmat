function line=findline(string,file)
% FINDLINE      string search in ASCII-files
% returns the line-number(s) of where in the file the given string is
% found.
%
% line = findline(string,file)
% 
% string        = string to search for
% 
% Handy for finding the number of headerlines in a file to specify when
% using TEXTREAD on datafiles of nonuniform number of headerlines. Just
% specify a unique expression/string that's always in the last headerline
% (and not below that).
%
% See also TEXTREAD

%Time-stamp:<Last updated on 03/06/26 at 18:32:01 by even@gfi.uib.no>
%File:</home/janeven/matlab/evenmat/findline.m>

fid=fopen(file,'r');                    % open the file
if fid==-1, 
   fprintf(1,'... Can''t open file %s\n',file); % skip if file not found
   line=[];
else
   contents=fread(fid,'char');          % read the headerfile
   fclose(fid);
   ahd=char(contents');                 % convert read ascii-code to one string
%   rets   = findstr(char(13),ahd); %DOS % find all end-of-lines in this string
   rets   = findstr(char(10),ahd);  %UNIX% find all end-of-lines in this string
   strpos = findstr(string,ahd);        % find position of string 
   for i=1:length(strpos)               % find the newlines
     rets_before_string = find(rets<strpos(i));% before string
     line(i)=length(rets_before_string)+1;% string is on the line after 
   end                                  % number of newlines
end
