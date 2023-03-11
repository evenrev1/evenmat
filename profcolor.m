function [h,X,Y,Z] = profcolor(x,y,Z)
% PROFCOLOR	Plots columns of data with non-uniform depths and NaNs.
% 
% [h,X,Y,Z] = profcolor(x,y,Z)
% 
% x	= column position vector or matrix. E.g., position of
%         profiles or simply subscripts for columns.   
% y	= depth matrix 
% Z	= data values at X,Y.
%
% h	= handle to a surface object, made by PCOLOR.
% X,Y,Z	= Complete set of matrices of equal size based on the 
%         input. Useful for marking of midpoints.
%
% All inputs must fit in size and Z must be a matrix.
% 
% See also PCOLOR EPCOLOR

% evenrev1@me.com https://github.com/evenrev1

% figure(11); clf; 

%clear sX sY sZ
if ndims(x)>2|ndims(y)>2|ndims(Z)>2, error('Max 2D input allowed!'); end
sX=size(x); sY=size(y); sZ=size(Z);
if any(sX==1), X=repmat(x(:)',sZ(1),1); else X=x; end
if any(sY==1), Y=repmat(y(:),1,sZ(2));  else Y=y; end
sX=size(X); sY=size(Y); sZ=size(Z);
if any(sY~=sZ|sX~=sZ), error('Input matrices must be of suitable size!'); end
clear x y

if size(X,2)<2
  g_x=X(1,1)+[-.5 .5];
else
    [ans,g_x]=buildgrid(X(1,:));
end
xlim(g_x([1 end]))
%xl(1)=X(1,1)-diff(X(1,1:2))/2; xl(2)=X(1,end)+diff(X(1,end-1:end))/2; xlim(xl);

hold on
for j=1:sX(2)
  z=[Z(:,j);NaN];   y=[Y(:,j);NaN]; 
  ~isnan(z(1:end-1));
  if ~all(~ans)
    find(ans);
    z(ans(end)+1)=z(ans(end)); 
    if ans==1, y(ans(end)+1)=y(ans(end))+1; % Just add one meter
    else y(ans(end)+1)=y(ans(end))+y(ans(end))-y(ans(end)-1); 
    end
    [g,g_y]=buildgrid(y); %g_y=[g_y;NaN];  
    %g_y(ans(end)+1)=y(ans(end))+y(ans(end))-g_y(ans(end-1));
    h=pcolor(g_x([0 1]+j),repmat(g_y(1:end-1),1,2),repmat(z,1,2));
    %pcolor(X(1,[0 1]+j)-diff(X(1,[0 1]+j))/2,repmat(g_y,1,2),repmat(z,1,2));
    %pcolor(repmat(X(:,j),1,2),repmat(g_y,1,2),repmat(z,1,2));
    %pcolor([0.5:1.5]+j,repmat(g_d,1,2),repmat([OX(1:9,301+j);NaN],1,2));
  end
end

%~isnan(Z); h=plot(X(ans),Y(ans)); set(h,'marker','.','markersize',15,'color','r','linestyle','none')

mima(Y); 
if ans(2)==ans(1),
  ylim(ans(1)+[-1 1]);
else
  ylim(ans+[-1 1]);
end

%%%get(gca,'xtick'); set(gca,'xtick',unique(round(ans)));

% A better sig or figstamp, since it relates to the Axes object and not coordinates in axes.
a1=gca; get(a1,'position');
a2=axes(gcf,'visible','off','position',[ans(1) ans(2)-.015 .01 .01]);
text(0,0,'profcolor');
set(gcf,'currentaxes',a1);

% axis ij; %shading flat; 
% ylim; ylim([0 ans(2)]);
% grid on; 

hold off
