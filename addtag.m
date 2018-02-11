function addtag(tag,h);
% ADDTAG	adds string to an object's tag
%
% addtag(tag,h);
%
% tag	= string to add to objects' tag
% h	= handle to object(s) to operate on (default = current object)
%
% See also SET

error(nargchk(1,2,nargin));
if nargin<2|isempty(h),		h=gco;	end

for i=1:length(h)
  otag=get(h(i),'tag');
  if any(findstr(otag,tag))	% already tagged with this tag
    return;
  else				% tag is new
    if isempty(otag),	sep=''; 
    else		sep='-';% tag-separator 
    end	
    ntag=strcat(tag,sep,otag);	% build whole tag
    set(h(i),'tag',ntag);	% set new tag
  end
end