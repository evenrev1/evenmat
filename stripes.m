function h=stripes(T,x0,ax,col,a)
% STRIPES	adds "striped" background
% Puts alternating blank and coloured stripes (patches) on background of
% current axis. This is often used to underline a periodicity of a plotted
% timeseries. 
% 
% h = stripes(T,x0,ax,col,a)
%							(Default values)
% T	= a) single valued period
%         b) vector explicitly describing positions 
%            of stripe edges				(axis tickmarks)
%         c) special options string:
%            'off'	: delete stripe-objects
%            'update'	: use to retain positioning when 
%			  rewdrawing stripes after 
%                         change of axis limits
% x0	= single valued starting-point for stripe
%         positioning (obsolete when T is not single)	(axis origo)
% ax	= character giving which axis to operate along	('x')
% col	= color specification				(light grey)
% a	= handle of axes to put stripes in
%
% h	= handle to the patch objects
%
% Old stripes are replaced unless the string 'stripes' are removed from
% their 'tag' property. 
%
% See also PATCH

if nargin<5 | isempty(a),	a=gca;			end
if nargin<4 | isempty(col),	col=[.9 .9 .9];		end
if nargin<3 | isempty(ax),	ax='x';			end
xlim=get(a,[ax,'lim']);
if nargin<2 | isempty(x0),	x0=xlim(1);		end
if nargin<1 | isempty(T),	
  get(a,[ax,'tick']); T=[ans ans(end)+diff(ans(end-1:end))];	
end

if	strcmp(lower(ax),'x'),	ya='y'; 
elseif	strcmp(lower(ax),'y'),	ya='x';
else	error('The axis-character must be ''x'' or ''y''!');
end

os=findobj(a,'tag','stripes');	% old stripes present?
if ischar(T) & ~isempty(os)
  switch T
   case 'off',		delete(os); return
   case 'update',	get(os,'userdata'); 
			T=ans.T; x0=ans.x0; col=ans.col; ax=ans.ax;	
			if ax=='y',ya='x'; else ya='y'; end
   otherwise		error('Unaplicable character input!');
  end
elseif ischar(T)
  error('No stripes in current plot!');
end

if issingle(T)				% build the Xdata matrix 
  x1=[fliplr(x0-2*T:-2*T:xlim(1)-2*T) x0:2*T:xlim(2)];
  x2=x1+T;
elseif isvec(T)
  T=T(:)';
  x1=T(1:2:end-1);
  x2=T(2:2:end);
end
x=[x1;x2;x2;x1];

ylim=get(a,[ya,'lim']);		% build the Ydata matrix 
y=[ylim(1);ylim(1);ylim(2);ylim(2)];
y=repmat(y,1,size(x,2));

delete(os);				% clear axis of old stripes
set(a,[ax,'LimMode'],'manual');	% lock the axis limits

					% THE PATCHING:
h=patch([ax,'data'],x,...
	[ya,'data'],y,...
	'clipping','on',...
	'facecolor',col,...
	'linestyle','none',...
	'userdata',struct('T',T,'x0',x0,'col',col,'ax',ax),...
	'tag','stripes',...
	'parent',a);
%	'userdata',{T,x0},...

get(a,'children');			% put the stripes in the back
set(a,'children',[ans(find(ans~=h));h],...
      'layer','top');			% put axis-box on top










