function sd=sigmadepth(sigma,d,s)
% SIGMADEPTH	Depths of isopycnals
%
% sd = sigmadepth(sigma,d,s)
%
% sigma	= density field (col=depth, row=time/distance/station)
% d	= depth matrix corresponding to the density field 
%	  (positive values)
% s     = vector of sigma value(s) to search for. This is usually
%	  the isopycnal levels you want the depth series for.
%
% sd	= matrix with depths of the chosen isopycnals, one row for each
%	  isopycnal. 
%
% See also MLD INTERP1Q NEIGHBOURS

% input tests
error(nargchk(3,3,nargin));
if size(sigma)~=size(d)
  error('Depth matrix must correspond to density matrix!');	end
%if find(isnan(sigma))~=find(isnan(d))
%  error('');	end
if ~issingle(s)&~isvec(s)
  error('Input isopycnals (s) needs to be single or vector!');	end
  
M=length(s);		% the number of isopycnals given
N=size(sigma,2);	% the number of profiles

% Comment: The simple linear interpolation is best at this, since
% non-changing values (indifferently stable/homogeneous waters) easily leads
% to singularities in other interpolation routines.

for j=1:N	% loop through all columns (profiles/stations)
  % F=INTERP1Q(X,Y,XI)
  % chooses automaticly the deepest (think it's the last) 
  find(~isnan(sigma(:,j)));
  if any(ans)
    sd(:,j)=interp1q(sigma(ans,j),d(ans,j),s);
  else
    sd(:,j)=nans(M,1);
  end
  % NaN's are returned for values of s outside the data in sigma.
end

% set all NaN for shallower than range to zeroes instead
%sd(find(repmat(min(sigma),M,1)>repmat(s(:),1,N)))=0;
% No, this is probably NOT the correct representation of outcropping of 
% isopycnals!




