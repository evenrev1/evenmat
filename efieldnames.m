function fn = efieldnames(s,removeempty,numbering)
% EFIELDNAMES	Fieldnames function that digs into all levels
% 
% fn = efieldnames(s,removeempty,numbering)
% 
% s		= Struct to be examined.
% removeempty	= logical whether to remove fieldnames of empty
%		  fields from list (default = false).
% numbering	= logical whether to add all numbered fieldnames 
%		  to list (default = true).
%
% fn		= string object of all fieldnames from all levels and
%		  multiples.  
% 
% See also STRUCT FIELDNAMES EGETFIELD

error(nargchk(1,3,nargin));
if nargin<3 | isempty(numbering),	numbering=true;		end
if nargin<2 | isempty(removeempty),	removeempty=false;	end

%eval([inputname(1),'=s;']);		% Use input name of struct to make name list valid
eval(['estruct.',inputname(1),'=s;']);	% Use input name of struct to make name list valid
fn=string(fieldnames(estruct));		% Start string to be buildt, with first level field names
fn=strcat('estruct.',fn);		% Prepend struct name to list
st=true(size(fn));			% Logical for fields to check for being struct themselves
sfi=find(st);				% Logical for hitherto unexamined struct fields
ri=false(size(fn));			% Logical for names finally to be removed from list

%tic 
while ~isempty(sfi) %& toc < 10
  % All fieldnames on this level are now in fn from last round and
  % those to be checked identified by indices in sfi.
  for i=1:length(sfi)				% Loop fields to be checked
    %fn
    %sfi(i)
    %fn(sfi(i))
    %if sfi(i)==20,keyboard;end
    if eval(char(strcat('iscell(',fn(sfi(i)),')')));	% If cell
      if eval(char(strcat('isstruct(',fn(sfi(i)),'{1})'))) % with structs
	eval(char(strcat('size(',fn(sfi(i)),'(:));')));	% Find size of field 
        % Need to assign numbering {1}, etc. to cell objects no matter their length.
	if numbering, k1=1; else, k1=ans(1); end 
	for k=k1:ans(1)				% Loop to make copies with {1}, {2} etc.
	  nn=strcat(fn(sfi(i)),'{',int2str(k),'}.',eval(['fieldnames(',char(fn(sfi(i))),'{',int2str(k),'})']));
	  fn=[fn;nn];				% Add all subfield names at end of list 
	  st=[st; true(size(nn))];		% Add same number of true values so they are checked next time
	  ri=[ri; false(size(nn))];		% Add same number of false values to the removal logical
	end
	ri(sfi(i))=true;	% Names of fields that are struct and has its subfields expanded, is to
				% be removed from final name list, below, since these names are
				% superfluous.
      end
    elseif eval(char(strcat('isstruct(',fn(sfi(i)),')')));				% If plain struct
      eval(char(strcat('size(',fn(sfi(i)),'(:));')));	% Find size of field 
      if ans(1)>1									% If more than one element struct
        % Need to assign numbering (1), (2), etc. if more than one:
	if numbering, k1=1; else, k1=ans(1); end 
	for k=k1:ans(1)				% Loop to make copies with (1), (2) etc.
	  nn=strcat(fn(sfi(i)),'(',int2str(k),').',eval(['fieldnames(',char(fn(sfi(i))),')']));
	  fn=[fn;nn];				% Add all subfield names at end of list 
	  st=[st; true(size(nn))];		% Add same number of true values so they are checked next time
	  ri=[ri; false(size(nn))];		% Add same number of false values to the removal logical
	end
	ri(sfi(i))=true;	% Names of fields that are struct and has its subfields expanded, is to
				% be removed from final name list, below, since these names are
				% superfluous.
      else										% If single-element struct 
        % Just add the subfield names, but no numbering:
	nn=strcat(fn(sfi(i)),'.',eval(['fieldnames(',char(fn(sfi(i))),')']));
	fn=[fn;nn];				% Add all subfield names at end of list 
	st=[st; true(size(nn))];		% Add same number of true values so they are checked next time
	ri=[ri; false(size(nn))];		% Add same number of false values to the removal logical

	ri(sfi(i))=true;	% Names of fields that are struct and has its subfields expanded, is to
				% be removed from final name list, below, since these names are
				% superfluous.
      end
    end % is it a struct?

    st(sfi(i))=false;		% When not a struct, or expanded, it should
				% not be examined again.

  end % loop fields to be checked
    
  sfi=find(st); % Indices to unexamined (new) structs. If there are any,
		% i.e. still any sfi left, the while-loop will go again
		% and treat these next.
  
end % while any sfi

if removeempty
  for j=1:length(fn)
    if eval(['isempty(',char(fn(j)),')'])
      ri(j)=true; % remove these too
    end
  end
end

% Remove the field names of fields that have deeper levels, from list:
fn=fn(~ri);

% Remove the dummy base name:
fn=replace(fn,'estruct.','');
