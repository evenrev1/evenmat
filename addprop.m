function addprop(varargin)
% ADDPROP	Add data to 'userdata'
% Adds field and value pairs to a structural in an object's userdata.
%
% First input is an handle to the object to have its userdata expanded,
% then this is followed by pairs of field names and values.

%Time-stamp:<Last updated on 06/12/13 at 21:43:14 by even@nersc.no>
%File:</home/even/matlab/evenmat/addprop.m>

if ishandle(varargin{1})
  h=varargin{1};
else
  error('First input must be object handle!');	
end
% if ~isint((nargin-1)/2) % worked for matlab versions < 7 
if mod((nargin-1),2)  % works for all
  error('Fields and values needs to come in pairs (even if empty)!');
end

ud=get(h,'userdata');			% extract existing information
if ~isstruct(ud), ud.data = ud; end	% if old format, put in field 'data'

for i=2:2:length(varargin)
  ud=setfield(ud,varargin{i},varargin{i+1});
end

set(h,'userdata',ud);			% put info back in

