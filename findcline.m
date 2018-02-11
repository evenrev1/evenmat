function [cx,cy]=findcline(x,y,xlim,tol)

% FINDCLINE	finds the point of highest gradient in columns of matrix
% Made for finding the depth of the halo-/pycno-/thermocline etc. of
% profiles. 
%
% [cx,cy] = findcline(x,y,xlim,tol)
%
% x     = position vector (or position-matrix)
% y     = corresponding vector or matrix for the data values 
%         (columns=profiles).
%	  x and y needs to be of same shape.
% xlim  = optional [min max] range of x in which to search for
%         the max gradient.  
% tol	= tolerance for similar gradients in the neighbourhood of the
%         strongest, single value in %  
%
% cx,cy = Coordinates of the ...cline, for each input profile.

%Time-stamp:<Last updated on 06/09/14 at 11:31:27 by even@nersc.no>
%File:</home/even/matlab/evenmat/findcline.m>

error(nargchk(2,4,nargin));
if nargin<3 | isempty(xlim) | ~(isvec(xlim) & length(xlim)==2)
  xlim=mima(x); 
end
if nargin<4 | isempty(tol), tol=10; end

if issingle(x)|issingle(y), error('Vector- or matrix-input, please!');end

if ismatrix(y)
  if ismatrix(x) & size(x)~=size(y)
    error('x and y needs to be of same size (corresponding values)!');
  elseif isvec(x)
    [M,N]=size(y);
    if length(x)~=M
      error('x and y needs to be of same size (corresponding values)!');
    else
      x=repmat(x(:),1,N);		% build a position-matrix from x
    end
  end
elseif isvec(y)
  if ismatrix(x), error('Can''t have position-MATRIX for a data-VECTOR!');
  elseif length(x)~=length(y), error('Vectors must be of equal length!');
  else y=y(:); x=x(:);
  end
end

%find(xlim(1)<=x(:,1) & x(:,1)<=xlim(2));% limit to given range 
%x=x(ans,:); y=y(ans,:);			% 
x<xlim(1) | xlim(2)<x;% limit to given range 
x(ans)=NaN; y(ans)=NaN;			% 
%val=(xlim(1)<=x | x<=xlim(2));% valid data

[M,N]=size(y);

[cx,cy]=deal(nans(1,N));		% preallocate memory
for j=1:N                               % loop through columns (profiles)
%  if find(isnan(y(:,j)));		% skip if any NaNs in limited
%    cx(j)=NaN; cy(j)=NaN;               % profile
%  else
    dx=nandiff(x(:,j));			% find increments 
    dy=nandiff(y(:,j));
    gr=abs(dy./dx);
    [mgr,i]=max(gr);             % find max gradient
    ii=find(mgr*(1-tol/100)<=gr&gr<=mgr*(1+tol/100));
    cy(j)=mean(y([ii(1) ii(end)+1],j));
    cx(j)=interp1q(y(:,j),x(:,j),cy(j));
    %cx(j)=x(i,j)+dx(i)/2;               % position of ...cline
    %cy(j)=y(i,j)+dy(i)/2;               % value at ...cline
  %end
end

%%% A plot if no output given and single profile
if nargout==0          % Plotted output if single profile
  fig findcline 4;clf;
  if  N==1
    plot(x,y,'bo-',cx,cy,'ro');
    legend('Data','Strongest gradient',0);
  else
    waterfall(x',repmat(1:N,M,1)',y');
    hold on 
    plot3(cx,1:N,cy,'r.');
    hold off
    %contourf(repmat(1:N,M,1),x,y);
    %line(cx,cy);
    title('Strongest Gradient');
  end
end
