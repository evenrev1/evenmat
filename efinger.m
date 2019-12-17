ddir='~/Arkiv/data/fingerprints';
files={'result_greenland_kjeldsen_mean.grd',...
       'result_antarctic_mean.grd',...
       'result_glaciers_mean.grd',...
       'result_dam_depletion_mean.grd'};
clim={[-1 0],[.23 .27],[-10 0],[.23 .27]};
clf;
m_proj('albers','lon',[0 32],'lat',[75 82]);
land=[.5 .5 .5];

LA.nya=78.928545; LO.nya=11.938015; % Ny Ålesund
LA.bar=78.066667; LO.bar=14.25; % Barentsburg

i=57; j=331:346; k=1:66; %t, lat, lon 
%i=57; j=1:360; k=1:720; %t, lat, lon 
Z=zeros(57,length(j),length(k));
for l=1:length(files)
  lon=ncread([ddir,filesep,files{l}],'x'); lon=lon(k);
  lat=ncread([ddir,filesep,files{l}],'y'); lat=lat(j);
  yr=ncread([ddir,filesep,files{l}],'t'); 
  z=ncread([ddir,filesep,files{l}],'RSL');
  [lon,lat]=meshgrid(lon,lat);
  z=permute(z,[3 2 1]); %z=shiftdim(z,2);
  z=z(:,j,k);
  Z=Z+z;

  figure(1); clf; set(gcf,'name',['trends_',files{l}(1:end-4)]);
  % trend estimate
  i=36:57; % 1993-2014
  %i=46:57; % 2003-2014
  [zt,yl,P,Q]=etrend(z(i,:,:),1); 
  tre=squeeze(P(1,:,:,:))*1000;  % m/yr -> mm/yr
  m_pcolor(lon-.25,lat-.25,tre);shading flat
  ca=caxis;
  m_grid;
  m_etopo2('contour',[-2000:200:-200],'edgecolor',[.8 .8 .8])
  m_gshhs_i('patch',land,'edgecolor',land);
  hp(1)=m_line(LO.nya,LA.nya); hp(2)=m_line(LO.bar,LA.bar);
  set(hp,'marker','.','markersize',20,'color','r');
  hc=colorbar;
  caxis(clim{l}); %caxis([-5 0]); %caxis(ca); %caxis([-3 3])
  ylabel(hc,[int2str(yr(i(1))),'-',int2str(yr(i(end))),' trend [mm/yr]']);
  %title(['trends_',files{l}(1:end-4)],'interpreter','none');
  figfile -G

  figure(2); clf; set(gcf,'name',['timeseries_',files{l}(1:end-4)]);
  %plot(yr,z(:,8,30),yr,z(:,1,1));
  for i=1:length(yr)
    ZZ.nya(i)=interp2(lon,lat,squeeze(z(i,:,:)),LO.nya,LA.nya);
    ZZ.bar(i)=interp2(lon,lat,squeeze(z(i,:,:)),LO.bar,LA.bar);
  end
  plot(yr,ZZ.nya,yr,ZZ.bar); 
  TRE.nya=interp2(lon,lat,tre,LO.nya,LA.nya);
  TRE.bar=interp2(lon,lat,tre,LO.bar,LA.bar);
  legend(['Ny Aalesund (',num2str(TRE.nya,'%3.1f'),' mm/yr)'],...
	 ['Barentsburg (',num2str(TRE.bar,'%3.1f'),' mm/yr)']);
  figfile -G
end

figure(1); clf; set(gcf,'name','trends_total_mass_exchange');
% trend estimate
i=36:57; % 1993-2014
%i=46:57; % 2003-2014
[zt,yl,P,Q]=etrend(Z(i,:,:),1); 
tre=squeeze(P(1,:,:,:))*1000;  % m/yr -> mm/yr
m_pcolor(lon-.25,lat-.25,tre);shading flat
ca=caxis;
m_grid;
m_etopo2('contour',[-2000:200:-200],'edgecolor',[.8 .8 .8])
m_gshhs_i('patch',land,'edgecolor',land);
hp(1)=m_line(LO.nya,LA.nya); hp(2)=m_line(LO.bar,LA.bar);
set(hp,'marker','.','markersize',20,'color','r');
hc=colorbar;
caxis(clim{3}); %caxis([-5 0]); %caxis(ca); %caxis([-3 3])
ylabel(hc,[int2str(yr(i(1))),'-',int2str(yr(i(end))),' trend [mm/yr]']);
%title('trends_total_mass_exchange','interpreter','none');
figfile -G


figure(2); clf;  set(gcf,'name','timeseries_total_mass_exchange');
for i=1:length(yr)
  ZZ.nya(i)=interp2(lon,lat,squeeze(Z(i,:,:)),LO.nya,LA.nya);
  ZZ.bar(i)=interp2(lon,lat,squeeze(Z(i,:,:)),LO.bar,LA.bar);
end
plot(yr,ZZ.nya,yr,ZZ.bar); 
TRE.nya=interp2(lon,lat,tre,LO.nya,LA.nya);
TRE.bar=interp2(lon,lat,tre,LO.bar,LA.bar);
legend(['Ny Aalesund (',num2str(TRE.nya,'%3.1f'),' mm/yr)'],...
       ['Barentsburg (',num2str(TRE.bar,'%3.1f'),' mm/yr)']);
figfile -G

save fingerprint_grid lon lat yr LO LA


% Yes, all the units are in meters,
% and positive numbers correspond to upward motion. Crust is indeed
% vertical land motion due to elastic deformation (only elastic response
% to ice and land water changes: no GIA etc). Geoid is indeed the geoid
% change in meters.

% Barystatic is the global-mean sea-level change associated with mass
% redistribution. Hence, you can compute the ratio between local and
% global sea-level change by dividing the RSL term by the barystatic
% term. Mass conservation is an internal model term (Because Geoid and
% Crust are not zero, when integrated over the oceans, the term RSL is
% equal to Geoid-Crust+Mass Conservation instead of Geoid-
% Crust+Barystatic). 

% Feel free to use the data in your report or other places where it's
% useful! You can cite my US east coast paper, which contains the correct
% description of this data:

% Frederikse, T., Simon, K., Katsman, C. A., & Riva, R. (2017). The
% sea‐level budget along the Northwest Atlantic coast: GIA, mass changes
% and large‐scale ocean dynamics. Journal of Geophysical Research:
% Oceans.
