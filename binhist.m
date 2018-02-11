function a=binhist(bin,x,edges,binname,varname,countlim)
% BINHIST       View the distribution of data in every bin
%
% a = binhist(bin,x,edges,binname,varname,countlim)
%
% bin      = the whole bin-structural from the binning-process (BIN1D,...)
% x        = vector of variable to distribute on (corresponding to
%            the vectors in the dataset that is binned)
% edges    = vector of the x-limits of the bars. Can be used to adjust
%	     the x-axis range             (default=step 1 over x-range)
% binname  = string naming the bin-field            (default=inputname)
% varname  = string naming the distributed variable (default=inputname)
% countlim = scalar upper limit of the histograms' vertical axes
%
% a        = vector of handles to the histogram axes
%
% Creates figures with histograms tiled according to the 2D x,y-bin-field
% (one figure for each z-plane if 3D-binning). Each histogram shows the
% distribution of the values of x used in that particular bin. A short
% figure-caption is also stamped on for identification.
%
% This can be used to test the homogeneity of the data-samples the bin-means
% are based on.
%
% See also BIN3D BIN2D BIN1D BUILDGRID 

error(nargchk(2,6,nargin));
if nargin<6 | isempty(countlim),        countlim=20;            end
if nargin<5 | isempty(varname),         varname=inputname(2);   end
if nargin<4 | isempty(binname),         binname=inputname(1);   end
if nargin<3 | isempty(edges),           edges=min(x):max(x);    end
if ~isfield(bin,'z'),                   bin.z=1;                end        

M=length(bin.y); N=length(bin.x); O=length(bin.z); MN=M*N;

for k=1:O                               % loop through each z-layer
  if O==1, lay=''; else lay=[' layer',num2str(k)]; end
  fig(['binhist ',varname,...           % with new figure for each
       ' in ',binname,lay],'lf');clf;
  for i=1:MN                            % loop through each bin
    subplot(M,N,i);
    %xx=x(mfind(bin.p,(k-1)*MN+i));     % obsolete function
    xx=x(find(ismember(bin.p,(k-1)*MN+i)));% faster
    if isempty(xx)
      nn=zeros(length(edges),1);        % In case of empty bin
    else
      nn=histc(xx,edges);
    end
    hb=bar(edges,nn,'histc','k');
    a(i)=gca;
  end
  set(a,'ylim',[0 countlim],...         % cosmetics
        'xlim',[edges(1),edges(end)],...
        'Visible','off');
  %   set(a(1),'visible','on','box','off',...
  % 	   'xaxislocation','top','yaxislocation','left',...
  % 	   'xtick',[edges(1),edges(end)],'ytick',[0 countlim]);
keyboard
ax=addaxis([edges(1),edges(end)],'b');
  set(ax,'xtick',[edges(1),edges(end)]);
  ay=addaxis([0 countlim],'r');
  set(ay,'ytick',[0 countlim]);
  figstamp(' ','Distributed variable is',varname,...
           'in bin-field',binname,...
           ', Layer =',num2str(k),'overwrite');
end

