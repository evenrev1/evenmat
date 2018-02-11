function list=getnamelist(h)
% GETNAMELIST   makes string from object's cellstring-array 'String' 
% 
% list=getnamelist(h)
%
% h	= a) object handle(s)
%	  b) structural containing field 'String'
% list	= cellstring vector with each input cellstring as a single string 

if isnumeric(h)
  for i = 1:length(h)
    lis='';
    str=cellstr(get(h(i),'String'));
    for j=1:length(str)
      lis=strcat(lis,str(j),{ ' '});
    end
    list(i)=cellstr(char(lis));           % strip away trailing spaces
  end  
elseif isstruct(h)
  for i = 1:length(h)
    lis='';
    str=cellstr(h(i).String);
    for j=1:length(str)
      lis=strcat(lis,str(j),{ ' '});
    end
    list(i)=cellstr(char(lis));           % strip away trailing spaces
  end  
end
