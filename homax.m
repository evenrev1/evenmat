function homax(aa,a,sep,f,ax)
% HOMAX		Homogeinization of ticksteps of different axes
%
% This function makes separation of ticks in several graphs equal to the
% eye, so that comparison of amplitudes in plots are realistic. Changes
% size of axes in given direction, then restacks the axes.
%
% homax(aa,a,sep,f,ax)
% 
% aa	= The standard, the axes all other will adjust their size to.
%			(default = first axes in a)
% a	= Vector of handles to the group of axes to homogenize
%			(default = all axes in current figure)
% sep	= Separation between the axes after they are restacked in
%	  normalized units (default = 0.05)
% f	= factor to scale the axes by, for additional adjustment of data
%	  unit to paperlength ratio.
% ax	= character giving the direction to homogenize: 
%			'x', 'y' (default), or 'z'
%	   NB! Only implemented for 'y' direction scaling.
%
% See also STACKAXES SUBPLOT SUBLAY MULTILABEL PLOTMARK

if nargin<5|isempty(ax),	ax='y';				end
if nargin<4|isempty(f),		f=1;				end
if nargin<3|isempty(sep),	sep=.05;			end
if nargin<2|isempty(a),		a=get(gcf,'children');		end
if nargin<1|isempty(aa),	aa=a(1);
				a=findobj(a,'visible','on',...
					  'type','axes');
				a=setdiff(a,findobj(a,'tag','legend'));
				a=sortaxeshandles(a);		end

if length(aa)>1, error('Only one standard axes can be used!');	end

%if any(findstr(get(gcf,'tag'),'crop')), return; end

A=length(a);

%change the ratios
rat=get(a,'DataAspectRatio');
pos=get(a,'position');
pa=get(aa,'position'); ra=get(aa,'DataAspectRatio'); RAT=pa(4)/ra(2);
for i=1:A
  set(a(i),'position',[pos{i}(1:3) f*RAT*rat{i}(2)]);
end

stackaxes(sep,a); % stack the plots (in the order of input a)

addtag('homax',gcf);

