function a = emph(a,fz,lt,mz)
% EMPH	thicken lines and enlarge fontsize of axis features
% Make axis features such as labels, title, axes and plotted lines
% bigger and clearer for use in a presentation.
% 
% a = emph(a,fz,lt,mz)
% 
% a	= handle of axis to be "emphasized" (default = current axis)
% fz	= single number fontsize (default = 12)
% lt	= single number linethickness (default = 2)
% mz	= single number markersize (default = 4)
%
% See also PLOTORDER SUBLAY 

error(nargchk(0,3,nargin));
if nargin<4 | isempty(mz),	mz=10;	end
if nargin<3 | isempty(lt),	lt=2;	end
if nargin<2 | isempty(fz),	fz=12;	end
if nargin<1 | isempty(a),	a=gca;	end

at=get(a,'title');
ayl=get(a,'ylabel');
al=get(a,'children');
atx=findobj(a,'type','text');
all=setdiff(al,atx);

a=a(:);
%at=[at{:}];
at=at(:);
%ayl=[ayl{:}];
ayl=ayl(:);
%al=[al{:}];
al=al(:);

set([a;at;ayl;atx],'fontsize',fz);
set([a;al],'linewidth',lt);
set([all],'linewidth',lt,'markersize',mz);
