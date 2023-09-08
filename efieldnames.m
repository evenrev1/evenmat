function fn = efieldnames(s,removeempty)
% EFIELDNAMES	Fieldnames function that digs into all levels
% 
% fn = efieldnames(s,removeempty)
% 
% s		= Struct to be examined.
% removeempty	= logical whether to remove fieldnames of empty
%		  fields from list (default = false).
%
% fn		= string object of all fieldnames from all levels and
%		  multiples.  
% 
% See also STRUCT FIELDNAMES EGETFIELD

error(nargchk(1,2,nargin));
if nargin<2 | isempty(removeempty), removeempty=false; end

%eval([inputname(1),'=s;']);				% Use input name of struct to make name list valid
eval(['estruct.',inputname(1),'=s;']);		% Use input name of struct to make name list valid
%eval(['fn=string(fieldnames(',inputname(1),'));']);	% Start string to be buildt, with first level field names
fn=string(fieldnames(estruct));			% Start string to be buildt, with first level field names
%fn=strcat(inputname(1),'.',fn);				% Prepend struct name to list
fn=strcat('estruct.',fn);				% Prepend struct name to list
st=true(size(fn));		% Logical for fields to check for being struct themselves
sfi=find(st);			% Logical for hitherto unexamined struct fields
ri=false(size(fn));		% Logical for names finally to be removed from list

while ~isempty(sfi)
  % All fieldnames on this level are now in fn from last round and
  % those to be checked identified by indices in sfi.
  for i=1:length(sfi)				% Loop fields to be checked
    
    if eval(char(strcat('iscell(',fn(sfi(i)),')')));	% If cell (assume it has structs, then)
      eval(char(strcat('size(',fn(sfi(i)),'(:));')));	% Find size of field 
      if ans(1)>1				% If more than one element, 
	for k=1:ans(1)				% Loop to make copies with {1}, {2} etc.
	  nn=strcat(fn(sfi(i)),'{',int2str(k),'}.',eval(['fieldnames(',char(fn(sfi(i))),'{',int2str(k),'})']));
	  fn=[fn;nn];				% Add all subfield names at end of list 
	  st=[st; true(size(nn))];		% Add same number of true values so they are checked next time
	  ri=[ri; false(size(nn))];		% Add same number of false values to the removal logical
	end
      else					% If just one element,
                                                % just add the subfield names, but no numbering:
	nn=strcat(fn(sfi(i)),'.',eval(['fieldnames(',char(fn(sfi(i))),')']));
	fn=[fn;nn];				% Add all subfield names at end of list 
	st=[st; true(size(nn))];		% Add same number of true values so they are checked next time
	ri=[ri; false(size(nn))];		% Add same number of false values to the removal logical
      end
      ri(sfi(i))=true;	% Names of fields that are struct and has its
			% subfields expanded, is to be removed from list
			% below, since they are superfluous.
     else
 
       if eval(char(strcat('isstruct(',fn(sfi(i)),')')));	% If struct
	eval(char(strcat('size(',fn(sfi(i)),'(:));')));		% Find size of field 
	if ans(1)>1				% If more than one element, 
	  for k=1:ans(1)			% Loop to make copies with (1), (2) etc.
	    nn=strcat(fn(sfi(i)),'(',int2str(k),').',eval(['fieldnames(',char(fn(sfi(i))),')']));
	    fn=[fn;nn];				% Add all subfield names at end of list 
	    st=[st; true(size(nn))];		% Add same number of true values so they are checked next time
	    ri=[ri; false(size(nn))];		% Add same number of false values to the removal logical
	  end
	else					% If just one element,
                                                % just add the subfield names, but no numbering:
          nn=strcat(fn(sfi(i)),'.',eval(['fieldnames(',char(fn(sfi(i))),')']));
	  fn=[fn;nn];				% Add all subfield names at end of list 
	  st=[st; true(size(nn))];		% Add same number of true values so they are checked next time
	  ri=[ri; false(size(nn))];		% Add same number of false values to the removal logical
	end
	ri(sfi(i))=true;	% Names of fields that are struct and has its
				% subfields expanded, is to be removed from list
				% below, since they are superfluous.
      end
    end
    st(sfi(i))=false;	% When not a struct or expanded above, it should
                        % not be examined again.
  end

  sfi=find(st); % Indices to unexamined (new) structs. If there are any,
                % i.e. still any sfi left, the while-loop will go again
                % and treat these next.
end

if removeempty
  for j=1:length(fn)
    if eval(['isempty(',char(fn(j)),')'])
      ri(j)=true; % remove these too
    end
  end
end

% Remove the field names of fields that have deeper levels from list:
fn=fn(~ri);

% Remove the dummy base name:
fn=replace(fn,'estruct.','');
