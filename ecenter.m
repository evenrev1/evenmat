function [I,J] = ecenter(R)
% ECENTER	Find best central point inside a gridded mask.
% 
% [I,J] = ecenter(R)
%
% R	A logical matrix with true values for your mask. 
%
% I,J	Pair of subscripts for the found center point, which you can
%	put into your position vectors/matrices for plotting text
%	etc. in the middle of the mask. 
%
% Finding the right place for text inside a masked region can be
% difficult. Masks can be separated, have scattered smaller regions, as
% well as single points. E.g., if the masked region is crescent shaped,
% CENTROID could easily place the center at a location outside of the
% mask. Instead, ECENTER iteratively zooms in on the most central and
% largest surface of the mask with a circle until the whole circle is
% inside the mask and then returns the indices for the center of that
% circle. Currently only operates with matrix indices as dimensions.
%
% If no output is requested, a demonstration animation of the process
% is shown.
% 
% See also CENTROID 

error(nargchk(1,1,nargin));
%%%if nargin<3 | isempty(X),   X=NN;   end

[M,N]=size(R);

if nargout==0, figure(1234); end

all_inside_true=logical(0);
while ~all_inside_true
  [I,J]=ind2sub([M,N],1:(M*N));  % All points
  [i,j]=find(R);		 % True points

  % Circle:
  jc=mean(j);		% Center of true points
  ic=mean(i);
  jr=max(j,[],'all')-jc; % j-radius
  ir=max(i,[],'all')-ic; % i-radius
  r=max([jr,ir])-1; % Subtract one to make sure it zooms
  [je,ie]=ellipse(r,r,0,jc,ic); % circle
  %[je,ie]=ellipse(jr,ir,0,jc,ic); % ellipse

  % Find all points inside circle:
  K=inpolygon(J,I,je,ie);
  J=J(K);I=I(K);
  K=sub2ind([M,N],I,J);
  
  % Test if everything inside is true now:
  all_inside_true=all(R(K),'all')|nnz(R(K))==1;
 
  % Change the logical matrix:
  ii=setdiff(1:M*N,K);	% Points outside ..
  R(ii)=0;		% .. are set to false

  if nargout==0
    clf;
    pcolor(R); shading flat
    hold on
    %scatter(j,i);
    %figure(18); clf; histogram(i); xlabel i
    %figure(19); clf; histogram(j); xlabel j
    plot(je,ie);
    %scatter(J,I);
    pause(.05);
  end
end

if nargout==0
  plot(jc,ic,'marker','o','markersize',5,'color','r');
end

J=round(jc); I=round(ic);
