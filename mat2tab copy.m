function fid=mat2tab(x,format,filename,perm)
% MAT2TAB       Matlab matrices into LaTeX tabular format
% Writes the input matrix to file formatted for tabular-environment in
% LaTeX. Filename of text will be the name of the input matrix/vector with 
% TeX-extension, i.e. 'argumentname.tex'. 
% Then simply use '\input{argumentname}' in your LaTeX-document.
% 
% This is handy, not only because you don't have to fiddle with the copying
% of numbers and inserting the separators, but also because you can set up
% this "bridge" between matlab and LaTeX once and for all for a table. Each
% rerun of your matlab analysis will be automaticly updated when compiling
% your LaTeX-document.   
% 
% fid=mat2tab(x,format,filename,perm)
%
% x        = the matrix. You have to organze the numbers the way you want
%            your  table. This and the LaTeX-formatting of the table, will
%            have to match (See example *) !   
% format   = The formatting of the lines in the file (see FPRINTF). 
%            You can omit the double backslashes and newline at the
%            end. Remember the &'s. If no \\ or \hline is desired,
%            just output  as explicitly given in the format string,
%            end this string by a single \. Read more about format in
%            FPRINTF. You can also omit the format altogether and get
%            '%6.2e &' for all columns.  
% filename = optional filename in case you don't wish to or can't use same
%            name as matrix (omit the '.tex', use same string as in
%            \input-statement).
% perm     = optional permission for file opening (See FOPEN). Gives
%            possibility to add to file instead of making new file with each
%            call. This can be used to put more LaTeX-coding into the
%            automaticly generated file  
%            HINT: MAT2TAB(1,'\\hline',name,'a'); (the matrix-input can be
%            given as a "phony" number when no numeric formatting is given)
%
% fid      = output file identifier (See FOPEN)
%
% EXAMPLE: A matrix    x = [1 5 7
%                           3 6 8]
%
%          into MAT2TAB(x,'%6.2e & %6.2e & %6.2e') will in file x.tex be
%
%                 1.00 &   5.00 &   7.00 \\ 
%                 3.00 &   6.00 &   8.00 \\
%
%          and can be put in a LATeX-table with
%
%          \begin{table} \caption{blablabla} \label{tab:blabla} 
%            \begin{tabular}[b]{|r|r|r|}                        <-- (*)
%              \hline 
%              $T [\degC]$ & $S [psu]$ & $ \sigma $\\           <-- (*)
%              \hline\hline
%              \input{x}              <<<<--- INPUT OF TABLE!!!
%              \hline
%            \end{tabular}
%          \end{table}
%
% TRICK:   If you have vectors you want to tabulate, you can always
%          concatenate them like this:
%          x and y are columnvectors, X=[x y] is a matrix with them as
%          columns. [x;y] puts vectors on top of eachother. Mind the
%          vectors' shape, col or row.
%          You can even input directly with MAT2TAB([x y],[],filename), 
%          but then you'll have to give filename. Empty format-input like
%          this gives default format. 
%
% see also SNIPPET FPRINTF FOPEN

%Time-stamp:<Last updated on 03/05/29 at 18:25:27 by even@gfi.uib.no>
%File:</home/janeven/matlab/evenmat/mat2tab.m>

error(nargchk(1,4,nargin));
if nargin <4 | isempty(perm)
  perm='w+'; % Delete the contents of an existing file or create new file,
             % and open it for reading and writing. 
end
if nargin <3 | isempty(filename)
  filename=[inputname(1),'.tex'];
else
  filename=[filename,'.tex'];
end
if nargin < 2 | isempty(format) % make a default format
  form='%6.2e &'; 
  format=form;
  [M,N]=size(x);
  for i=1:N-1
    format=[format,form];
  end
  format=format(1:length(format)-2); %remove the last '&'
end
if findstr(format,'\hline')   % cases when we don't want
  format=[format,' \n'];      % \\ TeX-newline
elseif strmatch(format(end),'\') % Ended with \ means plain string out
  format=format(1:end-1);
else  
  format=[format,' \\\\ \n']; % normal dataline with \\
end

x=x'; % fprintf reads matrix columnwise

fid=fopen(filename,perm);
%  fprintf(fid,'%% \n');
  fprintf(fid,format,x);
%  fprintf(fid,'%%');
fclose(fid);

if nargout==0
%  fprintf(1,'%% \n');
  fprintf(1,format,x);
%  fprintf(1,'%% \n');
end



