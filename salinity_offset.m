function [sal_offset,sal_offset_p] = salinity_offset(PRES,TEMP,SAL,pres,temp,sal,prlim,ptlim,LONG,LAT,T,long,lat,t,NAME,name)
% SALINITY_OFFSET	salintiy offset between two profiles
% 
% [sal_offset,sal_offset_p] = ...
%		salinity_offset(PRES,TEMP,SAL,pres,temp,sal,...
%				prlim,ptlim,...
%				LONG,LAT,T,long,lat,t,...
%				NAME,name)
%
% Works on two individual profiles and calculates difference in
% salinities on coexisting potential temperature levels, as well as on
% pressure levels. A figure is provided.
%
% PRES,TEMP,SAL = vectors with a profile's pressure, temperature,
%		  and salinity data, respectively.
% pres,temp,sal = vectors with another profile's pressure,
%		  temperature, and salinity data, respectively. 
% prlim		= two value vector of pressure range to compare
%		  within (default = [10 Inf]). Scalar input indicates  
%		  the minimum.
% ptlim		= two value vector of potential-temperature range to
%		  compare within (default = [-2 10]). Scalar input
%		  indicates the maximum.
% 
% The following inputs are optional information that will be displayed
% in figure:
%
% LONG,LAT,T	 = scalars of first profile's position and time.
% long,lat,t     = scalars of other profile's position and time.
% NAME		 = a string to mark first profile with.
% name		 = a string to mark the other profile with.
% 
% sal_offset	 = Output of the mean salinity difference between
%		   common potential-temperatures in both profiles.  
% sal_offset_p	 = Output of the mean salinity difference calculated
%		   by available data integrated over the selected
%		   pressure range.  
% 
% See also NEARPOS

% Last updated: Wed May 24 13:40:45 2023 by jan.even.oeie.nilsen@hi.no

% Check input:
error(nargchk(6,16,nargin));
if ~isvector(PRES) |~isvector(TEMP) |~isvector(SAL) | ~isvector(pres) |~isvector(temp) |~isvector(sal)  
  error('Inputs 1-6 must be vectors!'); 
end
PRES=PRES(:); TEMP=TEMP(:); SAL=SAL(:);
pres=pres(:); temp=temp(:); sal=sal(:);
if any(diff([length(PRES) length(TEMP) length(SAL)])), error('Main data vectors must have same length!'); end
if any(diff([length(pres) length(temp) length(sal)])), error('Other data vectors must have same length!'); end
if nargin<16 | isempty(name),	name='other';	end
if nargin<15 | isempty(NAME),	NAME='main';	end
if nargin<14 | isempty(t),	t=[];		end
if nargin<13 | isempty(lat),	lat=[];		end
if nargin<12 | isempty(long),	long=[];	end
if nargin<11 | isempty(T),	T=[];		end
if nargin<10 | isempty(LAT),	LAT=[];		end
if nargin<9  | isempty(LONG),	LONG=[];	end
if nargin<8  | isempty(ptlim),	ptlim=[-2 10];	end
if nargin<7  | isempty(prlim),	prlim=[10 Inf]; end

% Useful values calculated internally:
dx=sw_dist([LAT lat],[LONG long],'km');	% Distance between the two profiles
dt=t-T;					% Days other profile is past first profile
PTMP = sw_ptmp(SAL,TEMP,PRES,0);
ptmp = sw_ptmp(sal,temp,pres,0);

% Prepare for plots:
figure; 
set(gcf,'position',[1 1 1500 500]);
%set(gcf,'position',get(0,'screensize').*[1 1 1 .5]);

% SIMPLEST COMPARISON, ON PRESSURE:

% Find parts within selected ranges (Note that potential temperature is
% used for NaN removal, since it registers nans in any of the three
% parameters):
IND=find(~isnan(PTMP) & ...
	 prlim(1)<PRES & PRES<prlim(2));		% overlapping part of main profile (e.g., Argo)
ind=find(~isnan(ptmp) & ...
	 prlim(1)<pres & pres<prlim(2) );		% overlapping part of other profile (e.g., CTD)

% Calculate offset:
ctdsalt_a = interp1(pres(ind),sal(ind),PRES(IND));	% ctd salinity at argo pres 
~isnan(ctdsalt_a); IND=IND(ans); ctdsalt_a=ctdsalt_a(ans);
mind_offset_p=max(min(PRES(IND)),min(pres(ind)));	% Shallowest depth used
sal_offset_p=trapz(PRES(IND),SAL(IND)-ctdsalt_a)/diff(mima(PRES(IND))); % Integrate along depth to accomodate for inhomogeneous/missing data

% Simple offset profile-plot with info:
soa(1)=subplot(1,2,1); 
plot(PRES(IND),SAL(IND),'r.-',pres(ind),sal(ind),'g.-',PRES(IND),ctdsalt_a,'b.-')
legend(NAME,name,[name,' at ',NAME,' pressure levels'],'location','Best');
htit(1)=title([NAME,' average offset relative to ',name,' = ',num2str(round(sal_offset_p,3,'decimals')),...
	       ' @ p > ',int2str(mind_offset_p),' dBar']);
grid; xlabel PRES; ylabel PSAL; view(180,-90)


% COMPARISON ON POTENTIAL TEMPERATURE: 

% Find parts within selected ranges:
IND=find(~isnan(PTMP) & ...
	 ptlim(1)<PTMP & PTMP<ptlim(2) & ...
	 prlim(1)<PRES & PRES<prlim(2));		% overlapping part of main profile (e.g., Argo)
ind=find(~isnan(ptmp) & ...
	 ptlim(1)<ptmp & ptmp<ptlim(2) & ...
	 prlim(1)<pres & pres<prlim(2) );		% overlapping part of ctd profile (e.g., CTD)

ctdsalt_a = interp1(ptmp(ind),sal(ind),PTMP(IND));	% ctd salinity at argo ptemp 
~isnan(ctdsalt_a); IND=IND(ans); ctdsalt_a=ctdsalt_a(ans); % To be on the safe side
mind_offset=max(min(PRES(IND)),min(pres(ind)));		% Shallowest depth used
sal_offset=nanmean(SAL(IND)-ctdsalt_a);			% The salinity offset on ptmp
% We do not integrate, since potential-temperature does not represent
% volume in any way.

% ptmp-level based offset profile-plot with info:
soa(2)=subplot(1,2,2); 
plot(PTMP(IND),SAL(IND),'r.-',ptmp(ind),sal(ind),'g.-',PTMP(IND),ctdsalt_a,'b.-')
legend(NAME,name,[name,' at ',NAME,' ptmp levels'],'location','Best');
htit(2)=title([NAME,' average offset relative to ',name,' = ',num2str(round(sal_offset,3,'decimals')),...
       ' @ ptmp < ',num2str(ptlim(2)),' => p > ',int2str(mind_offset),' dBar']);
grid; xlabel PTMP; ylabel PSAL
set(soa(2),'ylim',get(soa(1),'ylim'));

% Info on timing and positons on both panels:
%soa(3)=subplot(1,3,3); 
leg{1}=[datestr(T),', ',num2str(LONG,'%10.3f'),'\circE, ',num2str(LAT,'%10.3f'),'\circN, ',NAME,'.'];
leg{2}=[datestr(t),', ',num2str(long,'%10.3f'),'\circE, ',num2str(lat,'%10.3f'),'\circN, ',name,'.'];
if ~isempty(dx) & ~isempty(dt)
  leg{2}=[leg{2},' (',int2str(round(dx)),' km away, ',int2str(round(dt)),' days past.)'];
end
p=get(soa(2),'position');
aleg=axes('position',[p(1)+p(3)+.01 p(2) .01 p(4)],'visible','off');
htxt=text(aleg,0,0,leg,'verticalalignment','top','horizontalalignment','left','rotation',90);

% p=get(soa(1),'position');
% aleg=axes('position',[p(1) p(2)-.08 p(3) .06],'visible','off');
% htxt=text(aleg,0,1,leg,'verticalalignment','top','horizontalalignment','left');

%htxt=text(soa(3),0,1,leg,'verticalalignment','top','horizontalalignment','left','rotation',90);
%set(soa(3),'visible','off')
set([htxt,htit],'fontsize',12);
% for i=1:2
%   p=get(soa(i),'position');
%   aleg=axes('position',[p(1) p(2)-.08 p(3) .06],'visible','off');
%   text(aleg,0,0,struct2cell(leg),'verticalalignment','bottom','horizontalalignment','left');
% end  




% Should we find a monotonic part? In both
% ptmp and pres at the same time? Is that a sign of layering that
% makes comparable parts?
% DPT=diff(PTMP(IND))<=0;	% True for PTMP decreasing (with depth)
% [GV,GI]=groups(DPT);	% Groups of PTMP decreasing 
% DGI=diff(GI);		% Stop minus start of groups
% [~,II]=max(DGI);	% Which is the longest group
% IND=IND(GV==II);	% Index to numbers in this group
% ind=find(~isnan(ptmp) & ...
% 	 min(PTMP(IND))<ptmp & ptmp<max(PTMP(IND(2))) );	% overlapping part of ctd profile (e.g., CTD)
% dpt=diff(ptmp(ind))<0;	
% [gv,gi]=groups(dpt);	
% dgi=diff(gi);		
% [~,ii]=max(dgi);	
% ind=ind(gv==ii);	
%plot(PRES(IND),PTMP(IND),pres(ind),ptmp(ind));


% And also, how to consider the volumentric consistency when going to ptemp?
% No, assume homogeneous. Even though there may be NaNs?
