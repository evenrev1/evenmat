function [h,omega] = nodaltide(lat,t)
% NODALTIDE	Nodal tide times series as function of latitude.
% 
% [h,omega] = nodaltide(lat,t)
%
% lat   = latitude of the location in degrees. Lat kan be a vector of
%         different positions.
% t	= your time coordinates in serial days.
% 
% h     = the nodal tide for your location(s) in mm. If multiple
%         latitudes input, the result will be a matrix with time as
%         first dimension and latitudes as second.
% omega = the amplitude(s) in a corresponding vector as lat.
%
% Citing Frederikse et al. (2016): "For the nodal cycle, we use the
% principle of Proudman [1960], which states that the nodal tide should
% almost certainly follow the equilibrium law, which reads:
%
% omega = alpha * (1 + k2 - h2)*(3*(sind(lat)).^2 - 1) 
%
% with tidal love numbers k2 = 0.36 and h2 = 0.60 [elastic], tidal
% magnitude alpha = 8.8 mm and latitude lat. Following Woodworth [2012],
% we calculate the self-attraction and loading response of this tidal
% load and add the resulting changes in geoid, crust and RSL to the
% equilibrium sea level response."
%
% Frederikse, T., R. Riva, M. Kleinherenbrink, Y. Wada, M. van den
% Broeke, and B. Marzeion (2016), Closing the sea level budget on a
% regional scale: Trends and variability on the Northwestern European
% continental shelf, Geophys. Res. Lett., 43, doi:10.1002/2016GL070750.
%
% Woodworth, P. L. (2012), A note on the nodal tide in sea level
% records, J. Coastal Res., 28(2), 316–323, doi:10.2112/JCOASTRES-D-11A-00023.1.
%
% See also TIDALFIT T_TIDE DATENUM

lat=lat(:)';

k2=0.36;	% the ratio of the additional potential (self-reactive force) produced by the deformation of the deforming potential.
h2=0.60;	% the ratio of the body tide to the height of the static equilibrium tide.
alpha=8.8;	% Amplitude (mm) at the equator

%1+k2-h2 = 0.76

omega = alpha * (1 + k2 - h2)*(3*sind(lat).^2 - 1) % Frederikse
%omega = alpha * 0.69 * (3*sind(lat).^2 - 1) % Woodworth???

t0=1922.7;	t0=datenum(t0,1,1); 
T=18.61;	T=T*365.25;	

[omega,t]=meshgrid(omega,t);
h=-omega.*cos(2*pi*(t-t0)/T);

if nargout==0
  %fig nodaltide; clf; 
  figure(10); set(gcf,'name','nodaltide'); clf; 
  plot(t,h);
  set(gca,'ylim',[-16 16],'xlim',mima(t))
  dateaxis(10)
  grid
  ylabel('Nodal tide  [mm]');
  legend([num2str(lat'),'^\circN'])
end
