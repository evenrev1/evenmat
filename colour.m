function cspec = colour(cnum)
% COLOUR	Numbered Colour-specs
% 
% cspec = colour(cnum)
% 
% Output is character color specification corresponding to the input
% integer number in from this list:
% 
%          1  b     blue      
%          2  g     green    
%          3  r     red      
%          4  c     cyan      
%          5  m     magenta 
%          6  y     yellow  
%          7  k     black 	 
%          ...      more colours (up to a total of 13)
% 
% See also GRAPH3D PLOT

col={[0 0 1],[0 1 0],[1 0 0],[0 1 1],[1 0 1],[1 1 0],[0 0 0],...
     [.7 .4 .2],[.35 .7 .6],[.14 .5 .7],[.4 .16 .7],[.7 .65 .34],[.7 .7 .7]};

cspec=zeros(length(cnum),3);
for i=1:length(cnum)
  cspec(i,:)=col{mod(cnum(i)-1,length(col))+1};
end
