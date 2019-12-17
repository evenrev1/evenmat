function z = eibe(lon,lat,t)
% EIBE	IBE calculation for any set of locations and time.
% Interpolates linearly in 3D using NCEP reanalysis SLP.
% 
% z = eibe(lon,lat,t)
% 
% lon, lat	position vectors or matrices
% t		time vector in serial days
%
% z		IBE in mm given as anomalies to the mean over the
%		reference period 1996-2014. 
%
% For example to regrid and find IBE on a global grid
%
%    [lon,lat,t]=meshgrid([1:350],[-85:85],datenum(1993:2015,6,1));
%    z=eibe(lon,lat,t);
%
% will return the IBE contribution at the chosen grid at chosen
% times. 
%
% See also 

%% EDIT HERE: %%%%%%%%%
ncepfile='~/Arkiv/data/ncep/slp.mon.mean.nc'; % The regular NCEP reanalysis 'slp' [mb]
%%%%%%%%%%%%%%%%%%%%%%%

lon<0; lon(ans)=lon(ans)+360;
lom=mima(lon); lam=mima(lat); tim=mima(t); % input area and period
tir=datenum([1996 2014],[1 12],[1 31]); % reference period
[M,N,O]=size(lon);

if datenum(1948,1,1) < tim(1) %& tim(2) < datenum(2017,10,31) % use NCEP
  pfile=ncepfile; % The regular NCEP reanalysis 'slp' [mb]
  ncdisp(pfile);
  ncread(pfile,'time');%,1,834);
  pt=datenum(1800,1,15,ans,0,0); % hours since 1800-01-01 00:00:0.0
  % Make sure the time span of the series cover the reference period.
  % times go monthly. 
  k=find(min([tir(1) tim(1)])-31<=pt&pt<=max([tir(2) tim(2)])+31);
  %pt=pt(k);
  datestr(pt([1 end]))
  % longitudes go 0:2.5:
  lo=double(ncread(pfile,'lon')); i=find(lom(1)-5<=lo&lo<=lom(2)+5);
  la=double(ncread(pfile,'lat')); j=find(lam(1)-5<=la&la<=lam(2)+5);
  %[lo,la]=meshgrid(lo(j),la(i)); mima(lo),mima(la)
  [la,lo,pt]=meshgrid(la(j),lo(i),pt(k)); 
  % sea level pressure (lon,lat,time) (i,j,k)
  slp=ncread(pfile,'slp',[i(1) j(1) k(1)],[length(i) length(j) length(k)]);
  % INTERPOLATE for the series
  z = interp3(la,lo,pt,slp,lat,lon,t);
  % INTERPOLATE for the reference mean, make, and subtract it
  rt=squeeze(pt(1,1,:)); rt=rt(tir(1)<=rt & rt<=tir(2));
  [ron,rat,rt]=meshgrid(lon(1,:,1),lat(:,1,1),rt);
  z0 = interp3(la,lo,pt,slp,rat,ron,rt);
  z0 = mean(z0,3);
  z = z-repmat(z0,[1,1,O]);
  clear ron rat rt z0 lo la pt slp
  %%%z = interp3(double(lo),double(la),pt,slp,2.5,65,736099); % 1.0056
end
% z is now PRESSURE ANOMALIES Dp [mb] relative to SLP mean for reference period.

% CALCULATE IBE [mm]
r0=1025;     % kg/m3
g=sw_g(lat); % m/s2
z=-100*z./(r0*g)*1000; % Unit 100 m -> m -> mm 
%IBE=-100*100*rowwise(Dp,'/',r0*g); % Unit 100 m -> m -> cm 
% Here Dp is the pressure fluctuations leading to IBE, r0 is the
% reference density of sea water taken as 1025 kg m^3, and g is the
% acceleration due to gravity. The pressure fluctuations are defined as
% the deviations from the mean over the period 1996–2014.
% 1 mb = 100 N/m2
% So unit is 100 m. Need to multiply with 100 for m and 1000 for mm. 


z=shiftdim(z,2); % lat, lon, t -> t, lat, lon 

