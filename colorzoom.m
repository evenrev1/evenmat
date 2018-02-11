function colorzoom(h)
% COLORZOOM	Limit caxis to range of data inside axis limits
% EPCOLOR and PCOLOR only!!!!
%
% colorzoom(h)
%
% h	= handle to axis (default = current axis)
%
% See also CAXIS 

error(nargchk(0,1,nargin));
if nargin<1|isempty(h),		h=gca;		end

for i=1:length(h)
  p=get(h,'children');			% find plot-objects in axis
					% 
  xl=get(h,'xlim');			% axis limits
  yl=get(h,'ylim');			% axis limits
  zl=get(h,'zlim');			% axis limits
  xd=get(p,'xdata');			% plot-object data
  yd=get(p,'ydata');			% plot-object data
  zd=get(p,'zdata');			% plot-object data
  [xd,yd]=meshgrid(xd,yd);		% x/y-vectors to matrices
					%
  % To search for facets, not lower left datapoints, ...
  xdl=nans(size(xd)); xdl(:,1:end-1) =xd(:,2:end); %move xdata left
  ydl=nans(size(yd)); ydl(1:end-1,:) =yd(2:end,:); %move ydata down
					%
  i=find(xl(1)<xdl & xd<xl(2) & ...
	 yl(1)<ydl & yd<yl(2) & ...
	 zl(1)<zd & zd<zl(2) );		% Data inside axis
  if ~isempty(i),
    cd=get(p,'cdata');			% Get color-data
    set(h,'clim',mima(cd(i)));		% Set colorlimit
  end
end
