function names = filenames(filenumbers,basisfilename)
% FILENAMES	Creates filename(s) based on input list of numbers 
% 
% names = filenames(filenumbers,basisfilename)
% 
% filenumbers   = single number or vector of numbers to replace
%		  the last characters of the ...
% basisfilename = single string ending with the necessary amount of
%                 e.g. zeros.
%
% Forcing a number string to have a specific length (fill with zeros)
% can also be done like NUM2STR(2,'%2.2d') -> '02'. 
% 
% See also NUM2STR

error(nargchk(1,2,nargin));
if nargin<2 | isempty(basisfilename), basisfilename='file000'; end

n=length(filenumbers);
names=char(repstr(basisfilename,n));
for i=1:n
   if     filenumbers(i)<10,   names(i,end)      =num2str(filenumbers(i));
   elseif filenumbers(i)<100,  names(i,end-1:end)=num2str(filenumbers(i));
   elseif filenumbers(i)<1000, names(i,end-2:end)=num2str(filenumbers(i));
   end      
end
names=cellstr(names);
