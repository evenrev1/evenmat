function rstr=repstr(string,M,N,opt)
% REPSTR        create cellstring array with identical cells
% Repeates a string in a cellstring, i.e. creates cellstr with same string
% in all elements. This is handy when creating format-strings for same
% format repeated.  REPSTR is reminiscent of ONES and ZEROS.
% 
% rstr=repstr(string,M,N,opt)
%
% string  = a single string 
% M       = the number of rows in output cellstring
% N       = the number of columns in output cellstring
%
% opt     = special option(s):
%           'char'  :  make _character_array_ of the MxN cellstr. This just
%                      glues together the created cellstring array.
%                       
% rstr    = the MxN cellstring with 'string' in all cells (or character array)
%
%             repstr('myfile',2,3)        => 'myfile' 'myfile' 'myfile'
%                                            'myfile' 'myfile' 'myfile'
%
%             repstr('%8.3f ',1,3,'char') => %8.3f %8.3f %8.3f 
%
% See also STRVCAT

%Time-stamp:<Last updated on 01/07/14 at 11:46:15 by even@gfi.uib.no>
%File:<d:/home/matlab/repstr.m>

error(nargchk(2,4,nargin));   % input-tests
if nargin<4 | isempty(opt)
   opt='';
end
if nargin<3 | isempty(N)
   N=1;
end

string=char(string);          % build cellstring array
rstr={''};
for j=1:N                                   % had to go in loop, because
   for i=1:M                                % cellstr cuts away spaces
      rstr{i,j}=string;                     % and repstring should repeat
   end                                      % everything
end                                     

if findstr(opt,'char')        % make character array of cellstr array
   row='';
   for j=1:N
      row=[row,char(rstr(i,j))];            % build a row of N x string
   end
   for i=1:M
      matr(i,:)=row;                        % repeat rows M times
   end
   rstr=matr;
end
