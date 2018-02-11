function ch=plotorder(h,dir,ax)
% PLOTORDER	Move plotted object to the back or front
%
% ch=plotorder(h,dir,ax)
%
% h	= a) vector of handles to objects that are to be moved 
%            relative to the rest of the axes' children or
%         b) string of specific type of object ('patch','line', etc.)
% dir   = string or character indicating which way to move object,
%         to 'f(ront)' or to 'b(ack)'.		(default='b')
% ax	= handle of axes to operate on		(default = current)
%
% ch    = vector of the objects' handles in the new order
%
% Example: To put all patches in a plot behind other objects, write 
%
%	   plotorder patch back
% 
% Can be used repeatedly to order several groups behind eachother.

%Time-stamp:<Last updated on 03/09/16 at 20:52:12 by even@gfi.uib.no>
%File:</home/janeven/matlab/evenmat/plotorder.m>

error(nargchk(1,3,nargin));
if nargin<3 | isempty(ax),	ax=gca;		end
if nargin<2 | isempty(dir),	dir='b';	end

if ischar(h)
  hty=findobj(ax,'type',h)
  hta=findobj(ax,'tag',h)
  h=[hty,hta]
  if isempty(h), error('String input must be a valid object type!'); end
end

h=h(:);

ch=get(ax,'children');

%order=[setdiff(ch,h);h]; % WARNING: SETDIFF sorts !!!!!
if strmatch(lower(dir(1)),'f')	| strmatch(lower(dir(1)),'u')	% to front
  order=[h;ch(find(~ismember(ch,h)))];
else
  order=[ch(find(~ismember(ch,h)));h];
end

ch=order;

set(ax,'children',ch);
