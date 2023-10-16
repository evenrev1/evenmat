function [y,yfn,parent] = egetfield(s,fn,fv,fvo)
% EGETFIELD	Get structure field contents at any level
% Searches the whole structure at all levels for the specified field
% name, and delivers results for all matching occurences. It is also
% possible to limit to specific values of the named field.  
%
% [y,yfn,parent] = egetfield(s,fn,fv,fvo)
% 
% s	 = Struct to be examined (single base-name, of struct).
% fn	 = char of desired field name.
% fv	 = desired value of field. 
% fvo	 = value of other field neighbouring the desired field.
%
% y	 = Cell with value(s) of specified field, or value of other
%	   field if fvo is input. 
% yfn	 = string object with full field name(s) corresponding to each y.
% parent = string object with full field name(s) of parent field(s)
%	   corresponding to each y. The parent is useful when your
%	   next operation is to find other subfields on same level as
%	   the one you searched for (fn).
% 
% In order to take advantage of the use of fv and parent to identify
% specific parts of a struct, one can follow this example:
%
%	[y,yfn,parent]=egetfield(npc,'parametercode','TEMP')
%	TEMP=eval(['getfield(',char(parent),',''reading''')])
%
% See also STRUCT GETFIELD EFIELDNAMES 

error(nargchk(2,4,nargin));
if nargin<4 | isempty(fvo), fvo=[]; end
if nargin<3 | isempty(fv), fv=[]; end

eval([inputname(1),'=s;']);				% Use input name of struct to make name list valid
eval(['names=efieldnames(',inputname(1),',false);']);	% Start string to be buildt, with first level field names

% Not used for field names at start!
% For field names in between:
parent2=names(contains(names,{['.',fn,'.'],['.',fn,'('],['.',fn,'{']}));	% Those with the wanted field name
split(parent2,{['.',fn,'.'],['.',fn,'('],['.',fn,'{']});			% Separate at field name
parent2=unique(ans(:,1));							% Only struct name(s) of higher level(s)
% For field names at end:
parent3=names(endsWith(names,['.',fn]));				% Those with the wanted field name
split(parent3,['.',fn]);						% Separate at field name
parent3=unique(ans(:,1));						% Only struct name(s) of higher level(s)

parent=[parent2;parent3];	% Combine
parent=parent(parent~="");	% and remove empty 

% If specified field is combined, split and merge start with parent:
split(fn,'.');
if length(ans)>1
  strcat(".",ans);
  parent=strcat(parent,ans(1:end-1));
  fn=ans(end); fn=char(replace(fn,'.',''));
end

% Get the contents of that specific field:
N=length(parent);
if N==0
  y=[]; 
  yfn = strcat(parent,'.',fn);
elseif N==1
  y{1}=eval(['getfield(',char(parent),',''',fn,''')']);
  yfn = strcat(parent,'.',fn);
else
  for j=1:N
    y{j,1} = eval(['getfield(',char(parent(j)),',''',fn,''')']);
    yfn(j,1) = strcat(parent(j),'.',fn);
  end
end

% If a specific value is part of the search, reduce the list:
if ~isempty(fv)
  if iscell(y)
    if isstruct(y{1})
      yy=cell2mat(y);
      yy=struct2cell(yy);
      yy=string(yy);
    elseif ischar(y{1})
      yy=cell2mat(pad(y));
      yy=strip(string(yy));
    end
  elseif ischar(y)
    yy=string(y);
  end
  % yy should be string or numeric by now:
  if isstring(yy) 
    strcmp(yy,fv);
  elseif isnumeric(yy)
    yy==fv;		
  end
  y=y(ans);
  yfn=yfn(ans);
  parent=parent(ans);
end

% If another field's value is sought as output:
if ~isempty(fvo) & ~isempty(parent)
  eval(strcat('y=',parent,'.',fvo,';'));
end

  
