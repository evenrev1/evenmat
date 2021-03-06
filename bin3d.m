function bin=bin3d(x,y,z,d,X,Y,Z,asc,err)
% BIN3D         3D binning of data vectors (MEAN or MVUE)
%
% bin = bin3d(x,y,z,d,X,Y,Z,asc,err)
%
% x,y,z = vectors or matrices of datapoint-positions corresponding to ...
% d     = vector or matrix of data to be binned
% X,Y,Z = bin-specifications for the three dimensions separately
%         (default: 10 bin structure over the range of positions).
%         See BUILDGRID on how to specify!
% asc   = Logical 1 or 0, on or off, for ASCII plotting of number of
%         datapoints (default = 1)
% err   = vector of measurement errors/weights. If given, the MVUE method
%         is used.   
%
% bin   = the results in a structural of 3D-arrays and vectors:
%         .n            number of points in bins (basis for mean-values)
%         .mean         estimated mean-values
%         .var          variance (sigma^2) for the bin. To calculate
%                       error-variance for the mean-values
%                       (sigma^2/N-1), use .n as N.  
%         .min  .max    min and max values
%         .x,y,z        mid-points/positions of bins	(vectors)
%         .xg,yg,zg     limits beetween bins		(vectors)
%
% The layers (matrices) of the arrays are designed for
% (.x,.y,.mean(:,:,k))-plotting, so the x-dimension runs along the
% arrays' 2nd dimension (along the rows) and the y-dimension along the
% arrays' 1st dimension (down the columns).
%
% Simple ASCII plotting of the number of datapoints in the bins is done
% to give an overview of number of data in bins: '0-9'=0-9 ; '.'=10-50 ;
% ':'=50-100 ; '*'=100-1000 ; '#'=1000+
%
% See also BUILDGRID BIN2D BIN1D

%Time-stamp:<Last updated on 14/10/29 at 16:41:00 by even@nersc.no>
%File:</Users/even/matlab/evenmat/bin3d.m>
                
%         .var          error-variance for the mean-values (sigma^2/N-1)

error(nargchk(4,8,nargin));
NN=10; % default number of bins
if nargin<9 | isempty(err), err=[]; end
if nargin<8 | isempty(asc), asc=logical(1); end
if nargin<7 | isempty(Z), Z=NN; end
if nargin<6 | isempty(Y), Y=NN; end
if nargin<5 | isempty(X), X=NN; end

% The full 3D-structure (all XG,YG,ZG) needs to be buildt here, based on
% the spans of all datapoints (in case a non-specific bin-spec is given). 
% The XG- and YG-bin-specs are then to be sendt down through 
% the BIN2D-BIN1D-system

[X,XG]=buildgrid(X,x);		% buildgrid also filters for matrix input
[Y,YG]=buildgrid(Y,y);		% of bin-spec
[Z,ZG]=buildgrid(Z,z);  	

O=length(Z); M=length(Y); N=length(X);

%bin.p=nans(size(d)); %(maybe unnecessary spec)      % data-tracker

% the binning for each z-bin
for k=1:O % loop through O bins along z-dimension ( z = k = / )
  if asc, fprintf('Processing z-layer %2d of %i :\n',k,O); end
  %if k==O,	index=find(ZG(k)<=z & z<=ZG(k+1) & ~isnan(d));
  %else		index=find(ZG(k)<=z & z< ZG(k+1)  & ~isnan(d));	end
  if k==O,	index=find(ZG(k)<=z & z<=ZG(k+1));
  else		index=find(ZG(k)<=z & z< ZG(k+1));	end
  if isempty(err)
    binz=bin2d(x(index),y(index),d(index),XG*i,YG*i,asc);
  else
    binz=bin2d(x(index),y(index),d(index),XG*i,YG*i,asc,err(index));
  end
  bin.n(:,:,k)          = binz.n;	% number of data in bin
  bin.mean(:,:,k)       = binz.mean;	% mean value
  bin.var(:,:,k)        = binz.var;	% variance
  bin.min(:,:,k)      = binz.min;	% min
  bin.max(:,:,k)      = binz.max;	% max
  %bin.p(index)  = (k-1)*M*N + binz.p;    % data-tracker (bin-number)
  %bin.i(index)  = (k-1)*M*N + binz.i;    % data-tracker (array indices)
end

bin.x=X;	bin.y=Y;	bin.z=Z;	% grid-mid out
bin.xg=XG;	bin.yg=YG;	bin.zg=ZG;	% grid-lims out

% plot if there are no outarguments
if nargout==0 & O<64
  disp('Creating plot...');
  fig bin3d fl;clf;
  [m,n]=sublay(O);
  for k=1:O
    subplot(m,n,k);
    epcolor(bin.x,bin.y,bin.mean(:,:,k));
    %epcolor(bin.x(:,:,k),bin.y(:,:,k),bin.mean(:,:,k));
    set(gca,'xtick',bin.xg,'ytick',bin.yg);
    %tallibing(bin.x(:,:,k),bin.y(:,:,k),bin.n(:,:,k));
    tallibing(bin.x,bin.y,bin.n(:,:,k));
    title(['z-layer number ',int2str(k)]); xlabel x; ylabel y;
    %ecolorbar(bin.mean(:,:,k));
  scanplot;
    colorbar;
  end
end

% DISABLED for speed:
%         .p            position in the bin-structure of the input data.
%                       A vector corresponding to the datavectors (x,y and
%                       d), with numbers showing what bin each datapoint is
%                       assigned to.  The numbering of bins is running
%                       through each row of x-bins, with y increasing, then
%                       likewise for each of the next z-layers.
%	  .i	        Like .p, but with array indices to .n, .mean and
%	                .var, instead of bin numbers (See below).  
%
% This means that the bin numbers in .p are _not_ array indices. The
% array indices are given in .i (see above). Furthermore, when plotting
% (.x,.y,.mean(:,:,k)) the matrices are "viewed" upside down if .y is
% increasing (not unusual).
