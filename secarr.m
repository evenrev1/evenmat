function [h,ht,xa,ya] = secarr(varargin)
% SECARR	Plot arrow perpendicular to a line from its mid point
% This can be used to add (e.g. transport) arrows to lines
% (e.g. sections). Arrow is scaled and labelled according to input length. 
% 
% [h,ht,xa,ya] = secarr(x,y,length,factor,zero,form)
%
% x,y    = coordinates for two endpoints of a straight line 
%          (e.g. a cross section).
% length = data input (speed, transport, etc.) governing the length
%          of the arrow to be drawn (default = 1).
% factor = scaling factor for the length of the arrow (default = 1). 
%          The arrow is drawn with a unit length equal to the length
%          of the straight line (the section) so length * factor
%          should be around 1 for sensible plotting. 
% zero	 = minimum length of arrow in same units as length (default = 0). 
%          If length is smaller than this value (before scaling),
%          length will be set to this 'zero'-value. 
% form   = text format of of the length label to be printed at the
%          arrow's end (e.g. '%3.1f' for '2.3'). If numeric, form is
%          interpreted as number of significant digits. 
%	   (default = 2)
%
%          Parameter/value pairs for ARROW can follow after these six
%          inputs.
%
% h	 = handle to arrow (patch object)
% ht	 = handle to arrow length label. 
% xa,ya  = coordinates for the arrow, in case you want to plot the
%          arrow yourself. If requested, arrow is not plotted.
%
% For m_map: INPUT MUST BE IN X,Y AND NOT LON,LAT!
% 
% See also ARROW ECURVE LINELABEL SECLINE

%Time-stamp:<Last updated on 07/06/08 at 11:45:42 by even@nersc.no>
%File:</Network/Servers/sverdrup-e3.nersc.no/home/even/matlab/evenmat/secarr.m>

tekst=logical(1);

%error(nargchk(2,5,nargin));

% find mid points and make arrows automaticly
e1=[1 0 0];e2=[0 1 0]; e3=[0 0 1];
%[xa,ya]=deal([]);

x	= varargin{1};
y	= varargin{2};

X1=[x(1),y(1),0];		% to start of section
X2=[x(end),y(end),0];		% to end of section
X=X2-X1;			% section vector
slength=abs(complex(X(1),X(2))); % length of section

if nargin<6 | isempty(varargin{6}), form=2; else form = varargin{6}; end 
if nargin<5 | isempty(varargin{5}), zero=0; else zero = varargin{5}; end 

if nargin<3 | isempty(varargin{3}), length=1; tekst=logical(0); else length = varargin{3}; end 
if nargin<4 | isempty(varargin{4}), factor=slength/length;      else factor = varargin{4}; end 

tomid=X/2;			% halfway vector
v=cross(e3,X); v=v/norm(v);	% normal to section
V=max(zero,length)*factor*v;% northward transport vector
[X1+tomid;X1+tomid+V];	% coordinates of northward transport vector
xa=ans(:,1);		% x-coordinates organised
ya=ans(:,2);		% y-coordinates organised
% V=(max(zero,flux{2}))*factor*v;% southward transport vector 
% [X1+tomid;X1+tomid-V];	% coordinates of southward transport vector
% xa(:,end+1)=ans(:,1);		% x-coordinates organised
% ya(:,end+1)=ans(:,2);		% y-coordinates organised

if nargout<3

  % ARROW:
  if nargin<7,	h=arrow([xa(1) ya(1)],[xa(2) ya(2)],...
			'LineStyle','-','Width',1,'baseangle',60);
  else		h=arrow([xa(1) ya(1)],[xa(2) ya(2)],varargin{7:end});
  end
  
  % TEXT: 
  if tekst
    if isnumeric(form),	ht=linelabel(xa,ya,num2str(sigdig(length,form)));
    elseif isstr(form),	ht=linelabel(xa,ya,num2str(length,form));
    end
  end

end

%ht=text(xa(2),ya(2),cellstr(num2str(length,'%3.1f')));
%ht=text(xa(2),ya(2),num2str(sigdig(length,2)));
% angle(diff(complex(xa,ya)));
% if     ans<pi* 1/6,	ha='left';   va='middle';
% elseif ans<pi* 2/6,	ha='left';   va='bottom';
% elseif ans<pi* 4/6,	ha='center'; va='bottom';
% elseif ans<pi* 5/6,	ha='right';  va='bottom';
% elseif ans<pi* 7/6,	ha='right';  va='middle';
% elseif ans<pi* 8/6,	ha='right';  va='top';
% elseif ans<pi*10/6,	ha='center'; va='top';
% elseif ans<pi*11/6,	ha='left';   va='top';
% elseif ans<pi*12/6,	ha='left';   va='middle';
% end
% set(ht,'HorizontalAlignment',ha,'VerticalAlignment',va)
% end

    %xt=get(h,'xdata');	yt=get(h,'ydata');	% arrowhead data (1)
