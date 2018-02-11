function ml_X = mlave(d,X,md)
% MLAVE		Average of property through mixed layer.
% 
% ml_X = mlave(d,X,md)
% 
% X	= property (e.g. salinity or temperature) vector or array, with
%         depth along first dimension (columns). 
% d	= Sample depths. Array corresponding to X, or vector of
%         common depths (corresponding to the columns of X).
%	  Must include and start at 0!
% md	= The mixed layer depth (MLD) 
%	  in a row vector or 1-by-... array.
% 
% ml_X	= The mixed layer averages in a row vector or 1-by-... array,
%	  corresponding to the input fields.
%
% Uses trapeziodal integration from surface to MLD in any water property
% profile and divides by MLD to find the bulk ML-value.
% 
% No output argument results in a plot of the original series and
% average. 
%
% See also MLD TRAPZ INTERPNM

%Time-stamp:<Last updated on 11/09/28 at 16:04:20 by even@nersc.no>
%File:</Users/even/matlab/evenmat/mlave.m>

error(nargchk(3,3,nargin));


% INPUT TEST AND RESHAPE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DX=size(X); Dd=size(d); 
if length(Dd)==2 & any(Dd==1)		% d IS A VECTOR
  if ~any(Dd==DX(1))			% but a vector that doesn't match
    error('Depth vector input must match column length of X!'); 
  elseif Dd(1)==1			% or just needs to be flipped 
    d=d';
    if DX(1)==1, X=X'; end		% or maybe both needed to be flipped
  end
  d=repmat(d,[1 DX(2:end)]);		% d -> matching array
elseif Dd~=DX				% OR ARRAY d AND X DOESN'T MATCH
  error('Array X and d input must both be of same size!');
end

ar=isarray(X);				% IF ARRAYS, -> MATRICES
if ar
  cols=prod(DX(2:end));
  X=reshape(X,DX(1),cols); d=reshape(d,DX(1),cols); 
end

[M,N,O]=size(X);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Preallocate memory:
[ml_X]=deal(nans(1,N)); 
jj=find(~isnan(md));            % profiles with non-nan MLD
% Loop profiles:
for j=1:length(jj)   
 D=d(:,jj(j));             % all depths
 dd=[D(D<md(jj(j)));md(jj(j))]; % only depths within ML
 ml_X(jj(j))=trapz(dd,interpnm(D,X(:,jj(j)),dd)) / md(jj(j));
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ar	% matrix was array, reshape output to match
   ml_X	=reshape(ml_X,[1 DX(2:end)]); 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargout==0 & DX(2)==1          % Plotted output if single profile
  fig mlave 34; clf; 
  %  plot(d,X,'bo-',md,ml_X,'g.-');
  plot(d,X,'bo-');
  axis;
  cage([ans(1) md],[ans(3) ml_X]);
  text(md,ml_X,num2str(ml_X));
  legend('Data','Average',0); 
  title('Spatial average of non homogenously sampled variable');
  set(gca,'xtick',d,'xgrid','on');
end
