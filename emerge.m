function [x,y,Z,JA,JB,IA,IB] = emerge(x1,y1,Z1,x2,y2,Z2,opt)
% EMERGE	Merge arrays by matching their coordinates
%
% Let's say you regularly download new timeseries data from a database,
% but from time to time it grows. Adding new data to your existing
% Matlab objects can then be a bit of a headache, since array sizes
% and coordinates do not match. EMERGE takes two such datasets and
% merges them . 
% 
% [x,y,Z,JA,JB,IA,IB] = emerge(x1,y1,Z1,x2,y2,Z2)
%
% x1	   = Coordinates for each column in Z1.
% y1	   = Coordinates for each row in Z1
% Z1	   = Data array of the first dataset.
% x2,y2,Z2 = Same as above, for the second dataset. These
%            will necessarily have to be in the same units as the
%            first dataset.
% opt      = character vector with the following options:
%		'f' : make figures showing overlap
%
% x1,y1,x2,y2 can be any format that UNION can take, but x1 and x2
% (and y1 and y2) must be the same object and content type.
%
% x,y,Z    = The merged dataset. x is the UNION of x1 and y1, and y
%            is the UNION of y1 and y2. No sorting is done. The
%            columns in Z1 and Z2 have been matched with the new x,
%            and the rows matched with the new y. Then Z2 is put 'on
%            top of' Z1 to make Z. NaNs do not replace values.
% JA,JB    = Indices that can be used to order any extra vectors that
%            corresponds with x1 and x2, in the following manner: 
%		x = [x1(JA),x2(JB)];  
% IA,IB    = Indices that can be used to order any extra vectors that
%            corresponds with y1 and y2, in the following manner: 
%		y = [y1(IA),y2(IB)];
%
% To make new versions of other data arrays corresponding to the input
% x1,y1 and x2,y2, you should just run EMERGE on those, in this manner:
%
%		[~,~,Q] = emerge(x1,y1,Q1,x2,y2,Q2);
%
% To see a more elaborate example TYPE EMERGE.
%
% By default replaces old with new data (i.e., Z1 values with non-NaN values in Z2).  


% See also UNION INTERSECT

% Jan Even Øie Nilsen, https://github.com/evenrev1

error(nargchk(6,7,nargin));
if nargin<7 | isempty(opt), opt=''; end


% prev.DATE -> x1 
% DATE -> x2
% new.DATE - x

scr=get(0,'screensize');
D=size(Z1);

% Sync x-coordinates (columns):
[x,JA,JB]=union(x1,x2,'stable'); % all dates
[~,JAo,JBo]=intersect(x,x1,'stable'); % indices to new for our prev columns 
[~,JAn,JBn]=intersect(x,x2,'stable'); % indices to new for current columns 

% Sync y-coordinates (rows):
[y,IA,IB]=union(y1,y2,'stable'); % all site IDs
[~,IAo,IBo]=intersect(y,y1,'stable'); % indices to new for our prev rows 
[~,IAn,IBn]=intersect(y,y2,'stable'); % indices to new for current rows 

% Put data in new data arrays:
M=length(y); N=length(x);
% Put the input arrays into empty arrays of new size:
%[So,To,Oo,Sn,Tn,On]=deal(nan(M,N,3)); % base arrays for prev and current in size of new
if length(D)<3
  [Zo,Zn]=deal(nan([M,N])); % base arrays for prev and current in size of new
else
  [Zo,Zn]=deal(nan([M,N,D(3:end)])); % base arrays for prev and current in size of new
end

% Put the input arrays in the correct positions of the empty arrays:
Zo(IAo,JAo,:)=Z1(IBo,JBo,:); Zn(IAn,JAn,:)=Z2(IBn,JBn,:); 

% Merge arrays (overwrite with new data where it's not nan):
Z=Zo; ~isnan(Zn); Z(ans)=Zn(ans);

% Testplots of the overlap:
if nargout==0 | contains(opt,'f')
  fn=findobj(0,'tag','emerge');
  ch=get(0,'children');
  if length(fn)<4 & ~isempty(ch), fn=max(ch.Number)+[1:4]; 
  else, fn=1:4; end
  figure(fn(1)); set(fn(1),'position',scr); epcolor(Zo(:,:,1));			colorbar; axis ij;  xlabel j; ylabel i;	title('First layer of first input array (Z1)');	
  figure(fn(2)); set(fn(2),'position',scr); epcolor(Zn(:,:,1));			colorbar; axis ij;  xlabel j; ylabel i;	title('First layer of second input array (Z2)');
  figure(fn(3)); set(fn(3),'position',scr); epcolor(Z(:,:,1));			colorbar; axis ij;  xlabel j; ylabel i;	title('First layer of merged array (Z)');	
  figure(fn(4)); set(fn(4),'position',scr); epcolor(Zn(:,:,1)-Zo(:,:,2));	colorbar; axis ij;  xlabel j; ylabel i;	title('First layer of difference (Z2-Z1)');       
  set(fn,'tag','emerge');
end







