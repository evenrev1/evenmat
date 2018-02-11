function [md,mlsig,sigma]=mld(S,T,d,dT,d0)
% MLD		Mixed layer depth
%
% [md,mlsig,sigma] = mld(S,T,d,dT,d0);
%
% S,T	= salinity and temperature vector or array, with depth along
%	  first dimension (columns). Must be of similar size.
% d	= Sample depths. Array corresponding to S and T, or vector of
%         common depths (corresponding to the columns of S and T).
% dT    = criterion on temperature shift to apply (default = 0.8).
% d0    = depth from which the "surface" values will be taken. This
%         is included so you can avoid surface inversions or missing
%         surface data (default = 8).
%
% md	= The mixed layer depth (MLD) in a row vector or 1-by-... array,
%	  corresponding to the input fields.
% mlsig = The sigma_t value at the base of the ML. Corresponding to md.
% sigma = The array with sigma_t profiles corresponding to S and T
%         (in case you'd like to have those at the same time).
%
% The MLD is calculated by a finite difference criteria method described by
% Glover and Brewer (1988): The MLD at each station is sought in the density
% profile calculated from temperature and salinity. A density corresponding
% to the MLD (a base density of the ML) is calculated by subtracting a
% temperature difference dT from the surface temperature, and the depth of
% this value is found by linear interpolation of the density profile.
%
% Note that MLD needs S and T, which means that using averaged (e.g. bin
% mean or monthly) profiles is not strictly correct, since the equation
% of state is not linear.
%
%   Glover, D. M., and P. G. Brewer, 1988: Estimates of wintertime mixed
%   layer nutrient concentrations in the North Atlantic. Deep-Sea Res.,
%   35, 1525-46.  
%
%   Kara, A.B., Rochford, P.A. and Hurlburt, H.E., 2000. An Optimal
%   Definition for Ocean Mixed Layer Depth. Journ. Geophys. Res.,
%   105(C7), 16803-21.  
%
% No output argument results in a plot of the profile and resulting
% MLD estimation.
%
% See also MLAVE SIGMADEPTH NEIGHBOURS SWSTATE

%Time-stamp:<Last updated on 11/10/05 at 14:40:44 by even@nersc.no>
%File:</Users/even/matlab/evenmat/mld.m>

if nargin<5 | isempty(d0), d0=8; end
if nargin<4 | isempty(dT), dT=0.8; end

DS=size(S); DT=size(T); Dd=size(d); 
if length(Dd)==2 & any(Dd==1)		% d is a vector
  if ~any(Dd==DS(1))			% but a vector that doesn't match
    error('Depth vector input must match column length of S and T!'); 
  elseif Dd(1)==1			% or just needs to be flipped 
    d=d';
  end
  d=repmat(d,[1 DS(2:end)]);		% d -> matching array
elseif DS~=DT | Dd~=DS			% OR array d, S and T doesn't match
  error('Salinity, temperature, and array depth input must all be of same size!');
end

ar=isarray(S);				% if arrays, -> matrices
if ar
  cols=prod(DS(2:end));
  S=reshape(S,DS(1),cols); T=reshape(T,DS(1),cols); d=reshape(d,DS(1),cols); 
end

[M,N,O]=size(S);

% calculate density field
[ans,sigma]=swstate(S,T,0);				% sigmat
% mixed layer sigma (using first row as surface values)
% MAYBE CHANGE THIS TO LOWER HERE, OR IN ASSIGNMENT???
%
% YES. Inserted here a top depth choice:
[i,j]=find(d<d0); 

if isempty(i), [md,mlsig]=deal(NaN); return; end

%[i,[diff(i);NaN],[diff(i)~=1;NaN],j]
diff(i)~=1;
i= [i(ans);i(end)];
j= [j(ans);j(end)]; 
%[i,j]
ii=sub2ind([M N],i,j);
%keyboard
[ans,mls]=swstate(S(ii),T(ii)-dT,0);		% sigmat
mlsig=nans(1,N); 
mlsig(j)=mls;

%[ans,mlsig]=swstate(S(1,:),T(1,:)-dT,0);		% sigmat

% Since (MLD-)densities are different from profile to profile we have to
% loop here. Matrix or array input to the sigmadepth function is intended
% for finding isopycnals:
%N=size(mlsig,2);
for j=1:N
  md(j)=sigmadepth(sigma(:,j),d(:,j),mlsig(j));
end
% sigmadepth needs depth along columns and profiles along rows

if ar			% matrix was array, reshape output to match
   md	=reshape(md,[1 DS(2:end)]); 
   mlsig=reshape(mlsig,[1 DS(2:end)]); 
end
 

if nargout==0 & N==1 & O==1           % Plotted output
  fig mld 34; clf; 
  plot(sigma,-d,'.-');
  line([mlsig mlsig],ylim);
  line(xlim,-[md md]);
  %  set(gca,'xtick',mlsig,'ytick',-md)
  grid on
  title('Mixed Layer Depth');
end


