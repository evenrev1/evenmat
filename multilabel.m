function h=multilabel(str,pos,a,sep,varargin)
% MULTILABEL    Common labels for muliple axes
%
% h = multilabel(str,pos,a,sep)
%
% str   = string of label
% pos   = character input of side of axes to put label on:
%         'l'eft (default), 'r'ight, 'b'ottom, 't'op
% a     = handles to axes to "embrace" (default = all)
% sep   = separation between labels and axes (default = .02/.05 normalized)
%
% h     = vector of handles to the mulitlabel objects
%         [xlabel axes (hidden), xlabel text]
%
% The inputs described here can be followed by parameter/value pairs to
% specify additional properties of the text.
%
% See also TITLE XLABEL

% Places an invisible axis at the desired position, and adds a
% text-object in its origo. Rotates as necessary.

if nargin<2|isempty(pos),  pos='l';                                     end
if nargin<3|isempty(a),    
  a=findobj(gcf,'type','axes');                 % All axes in fig
  findobj(a,'tag','multilabel','type','axes');  % Multis among those
  a=a(~ismember(a,ans));                        % are removed
end
ca=gca;		% know which are the current axes

uni=get(a(1),'units'); set(a,'units','normalized');

if nargin<4|isempty(sep),  if length(a)==1,sep=.02;else,sep=.05;end;    end
if nargin<1|isempty(str),  str='';                                      end

a=a(:)';

findobj(gcf,'tag','multilabel',...      
        'userdata',struct('pos',pos,'parents',sort(a))); % lab with same specs
delete(ans);                                             % are deleted

get(a,'position');
if length(a)==1,        pa=ans;                 % Chosen axes' positions:
else                    pa=cat(1,ans{:});       
end

x1=min(pa(:,1));                y1=min(pa(:,2));
x2=max(pa(:,1)+uplus(pa(:,3))); y2=max(pa(:,2)+uplus(pa(:,4))); 

                                        % Corners of the cluster of axes:
c(1)=x1-sep;                            %  6    _______
c(3)=x2+sep;                            %    y2|_______|
c(2)=mean(c([1 3]));                    %  5    _______
c(6)=y2+sep;                            %    y1|_______|
c(4)=y1-sep;                            %  4   x1     x2
c(5)=mean(c([4 6]));                    %     1    2    3

switch pos
 case 'b', po=[c(2),c(4),.01,.01];  rot=  0;
 case 't', po=[c(2),c(6),.01,.01];  rot=  0;
 case 'r', po=[c(3),c(5),.01,.01];  rot= 90;
 otherwise po=[c(1),c(5),.01,.01];  rot= 90;
end

h(1)=axes('position',po,...
          'visible','off','tag','multilabel',...
          'userdata',struct('pos',pos,'parents',sort(a)));
h(2)=text(0,0,str,...
          'horizontalalignment','center','verticalalignment','middle',...
          'rotation',rot,...
          'tag','multilabel',...
          'userdata',struct('pos',pos,'parents',sort(a)));

%set(gcf,'currentaxes',a(end));  % make last of the included axes current
set(gcf,'currentaxes',ca);  % make the initially current axes current now

set(a,'units',uni);  % PS!  sets all axis units equal to the first!!