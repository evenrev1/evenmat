function [J,k,L]=its(c,opt)
% ITS           Integral Time Scale
%
% [J,k,L] = its(c,opt)
%
% c     = the autocorrelation functions as provided by AUTOCORR, with lag
%         as 1st dimension (along columns/each column represent a timeseries)
% opt   = option character:
%            'z' : Integrate only to 1st zero-crossing of c_k
%            'n' : Never stop integration at 1st zero-crossing of c_k
%
% J     = The approximated integral time scale. 
%         For array input, J is 1-by-...
% k     = the lag to which the integration for J is done
% L	= logical array true for diverging J
%
% Due mainly to presence of low-frequency components in a time series, all
% observations are not independent. This has implications for the
% calculation of confidence limits. An effective number of degrees of
% freedom then becomes N*-1 instead of the customary N-1, where
%
%       N* = N/J,     J_k = cumtrapz(c_k),    k=0,...,M  , 
%
% ie. the integral of c_k from zero to k, where c_k is the (normalized)
% autocorrelation function at lag k. Since J_k seldom converge to a constant
% variable, the maximum of the calculated J_k is taken as the integral time
% scale J. However, if the maximum occurs in the end 1/10th of the
% lag-range, chances are (if M is reasonably large) that J is diverging
% severely. In ths case, J is found by integrating only to the first
% zero-crossing of the autocorrelation function (Emery and Thomson, 1997).
%
% The dimensionless J has to be multiplied by the sampling period to get a
% unit of time, and become a proper time scale.
%
% Results are plotted if no output arguments are given.
%
% An example of usage and a good explanation are found in 
%
%   S. Tabata, 1989. Trends and Long-term Variability of Ocean Properties
%   at Ocean Station P in the Northeast Pacific Ocean. Geophysical
%   Monograph, 55, p 113-132.
%
% which refers to 
%
%   G.V. Bayley and J.M. Hammersley, 1946. The "Effective" Number of
%   Independent Observations in an Autocorrelated Time Series. 
%   J.Roy.Stat.Soc., 88(2), p 184-197   
% 
%   John L. Lumley and Hans A. Panofsky, 1964. The Structure of
%   Atmospheric Turbulence. Interscience Publishers.
%
% but the theory is more easily accessed in
%
%   Emery,W.J. and Thomson,R.E., 1997. Data Analysis Methods in Physical
%   Oceanography. Pergamon Press. 634 pp.
%
% See also AUTOCORR CORRCOEF COV CUMTRAPZ SINGULARPLOT (eveneof)

error(nargchk(1,2,nargin));
D=size(c); M=D(1)-1; cols=prod(D(2:end));
if nargin<2 | isempty(opt),     opt=' ';        
else                            opt=opt(1);     end

c=c(:,:);                                       % Array -> matrix

Jk=cumtrapz(c);                                 % The integration

if nargout==0                                   % ... plot (like Tabata)
  fig its 24; clf;
  if cols < 7
    [ax,h1,h2]=plotyy(0:M,c,0:M,Jk);
    set(h2,'linestyle','--');
    xlabel k; ylabel c_k; grid % title('Integral Time Scale');
    set(gcf,'currentaxes',ax(2)); ylabel J_k;
    legend([h1,h2],strvcat(strcat('c_k(x_',int2str([1:cols]'),')'),...
                           strcat('J_k(x_',int2str([1:cols]'),')')),2);
  else
    ax(1)=subplot(2,1,1); 
    contourf(0:M,1:cols,Jk','edgecolor','none');
    ecolorbar(Jk,[],'J_k',[],[],'edgecolor','none'); ylabel('timeseries #'); xlabel k; 
    title('Integral Time Scale');
    ax(2)=subplot(2,1,2); 
    contourf(0:M,1:cols,c','edgecolor','none');
    ecolorbar(c,[],'c_k',[],[],'edgecolor','none'); ylabel('timeseries #'); xlabel k; 
    title('Autocorrelation');
  end
end

[J,k]=max(Jk);                                % Find the max
L=k>0.9*M;
if opt=='z'
  jj=1:cols;                                    % all at 1st zero X-ing
elseif opt=='n'
  jj=[];
else
  jj=find(L);                             % Those who have max at end
end

if any(jj)                                      % If any diverging J_k
  ii=ceil(interpnm(flipud(c(:,jj)),flipud([1:M+1]'),0,'s'));
  isnan(ii); 
  jjn=jj(ans); ii=ii(~ans); jj=jj(~ans); % No zero-crossing in c
  J(jjn)=NaN;                                           % no existing J = NaN
  J(jj)=Jk(sub2ind([M+1 cols],ii,jj));% J at first zero crossing
  k(jj)=ii;                                     % The (corrected) lag
end

J(J<1)=1;                               % In case of "total" independence

J=floor(J);

J=reshape(J,[1 D(2:end)]);                 % Matrix -> array
k=reshape(k,[1 D(2:end)]);                 % Matrix -> array
L=reshape(L,[1 D(2:end)]);                 % Matrix -> array


