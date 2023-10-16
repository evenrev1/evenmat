function [x,t] = valuetype(x,type)
% VALUETYPE	Returns or changes the valuetype.
% 
% [x,t] = valuetype(x,type)
% 
% x	= Single object to be changed. 
% type	= String of one of the valueTypes: 
%	   'STR'	: char or string
%	   'DEC'	: decimal, but can have integer value
%	   'INT'	: integer (not necessarily uint) 
%	   'DATETIME'	: 'yyyy-mm-ddTHH:MM:SS'
%	   'DATE'	: 'yyyy-mm-dd'
%	   'FLT'	: a true float, not of integer value
%	  If a valid type is input, x will be tested and its
%	  value type changed to type if necessary. For 'DATETIME' and
%	  'DATE' there is no change that can be done. For 'DEC'
%	  integer values will also pass, not just decimals; use 'FLT'
%	  for strictly testing for floats. 
% 
%	  If type is not given, the function simply tests which type
%	  x is. 
%
% x	= The (possibly) changed input x. If changed to empty, means
%	  both test and conversion failed. Or, for simple test, char
%	  output of the valueType from list above. 
% t	= Numeric indicator for test result; empty for false and a
%	  serial day for true or successful change of type. For
%	  'DATETIME' or 'DATE', it's the serial day of the char input
%	  x, while for other value types it is the serial day of
%	  midnight yesterday (just to have something that will likely
%	  fall into the interval of a reality check). But for simple
%	  tests, t=NaN;
%
% An input x that is struct, cell, NaN, or empty is simply piped through
% to output. 
% 
% See also NUM2STR STR2NUM ISCHAR ISNUMERIC ISINTEGER DATENUM


error(nargchk(1,2,nargin));
if nargin<2 | isempty(type), type=''; end

if isstring(type), type=char(type);
elseif ~ischar(type), error('Input ''type'' must be string or char!');
end
type=upper(type);

if ~ischar(x) & ~isscalar(x) & ~isempty(x), error('Input ''x'' must be single!');
end

t=[]; % Time in case of valueType 'DATETIME' or 'DATE'

if isstring(x), x=char(x); end
if iscell(x), return; end
if isstruct(x), return; end
if isnan(x), return; end
%if isempty(x), return; end

if ~isempty(type) % Check if x is or can be the correct value type

  % Transform empty char to empty numeric to avoid the trouble with
  % functions like str2double returning NaN:
  if isempty(x), x=[]; end
  
  switch type
   case 'STR'
    if ~ischar(x)
      try, x=num2str(x); t=floor(now-1); % Success
      catch, x=''; 
      end
    else
      t=floor(now-1); % True (no change)
    end
   case 'INT'
    if ischar(x)
      try, x=str2double(x); 
	if x~=round(x) | isnan(x), x=[]; 
	else, t=floor(now-1); % Success
	end 
      catch, x=[];
      end
    elseif isnumeric(x) 
      if x~=round(x), x=[]; 
      else, t=floor(now-1); % True (no change)
      end 
    else
      x=[];
    end
   case 'DEC'
    if ~isnumeric(x)
      try, x=str2double(x); 
	if isnan(x), x=[]; 
	else, 
	  t=floor(now-1); % Success
	end
      catch, x=[]; 
      end
    else
      t=floor(now-1); % True (no change)
    end
   case 'FLT'
    if ~isnumeric(x)
      try, x=str2double(x); 
      catch, x=[]; return
      end
    end
    if x==round(x) | isnan(x), x=[]; 
    else
      t=floor(now-1); % Success/true
    end
   case 'DATETIME'
    if ~ischar(x)
      x='';
    else
      if length(x)==19
	try 
	  t=datenum(x,'yyyy-mm-ddTHH:MM:SS');  
	catch
	  x='';
	end
      else 
	x='';
      end
    end
   case 'DATE'
    if ~ischar(x)
      x='';
    else
      if length(x)==10
	try 
	  t=datenum(x,'yyyy-mm-dd');  
	catch
	  x='';
	end
      else 
	x='';
      end
    end
   otherwise
    error(['Wrong valueType ',type,' entered as type! Must be ''STR'', ''DEC'', ''INT'', ''DATETIME'', ''DATE'', or ''FLT''.'])
  end

else % Just get the value type of x
  t=nan;
  if ischar(x)
    if length(x)==19
      try
	t=datenum(x,'yyyy-mm-ddTHH:MM:SS');  
	x='DATETIME';
      catch
	x='STR';
      end
    elseif length(x)==10
      try
	t=datenum(x,'yyyy-mm-dd');
	x='DATE';
      catch
	x='STR';
      end
    else
      x='STR';
    end
  elseif isnumeric(x)
    if x==round(x)
      x='INT'; 
    else
      x='DEC';
    end
  else
    x='';
  end
end
