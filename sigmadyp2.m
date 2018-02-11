function sdyp=sigmadyp2(t,d,SIGMA,dens)
% SIGMADYP      finds depth of isostere/isopycnal in density-field
% Finds the isolines for a given density by the function CONTOURS and smoothes
% them into a one-to-one function (without loops or hoops) using TWINE.
% Recommended only when depth is a dimension of the field, since it assumes
% that the isosteres are one-to-one functions.
%
% sdyp = sigmadyp(t,d,SIGMA,dens)
%
% t           = matrix of the horizontal- or time-ordinates
% d           = matrix of the depths-ordinates
% SIGMA       = matrix of the density field
% dens        = single number of the specific density for the isostere
%
% sdyp   = vector of depth of isostere at the given positions/times t(:,1)
%
% See also CONTOURS TWINE SW_DENS

%Te-stamp:<Last updated on 01/01/30 at 22:17:04 by even@gfi.uib.no>
%Fe:<d:/home/matlab/sigmadyp2.m>
sdyp=nans(size(SIGMA));
for i=1:length(dens)
  c=contours(t',d',SIGMA',[dens(i) dens(i)]);
  c=c(:,2:end);
  c=c(:,find(1948<c(1,:) & c(1,:)<2000));
  [sstid,ssdyp]=twine(c);
  sdyp(:,i)=interp1(sstid,ssdyp,t(:,1));
end


