function [PRESqcn,TEMPqcn,PSALqcn] = check_profiles(PRES,TEMP,varargin)
% CHECK_PROFILES	Check flags in hydrographic profile.
%
% This is a tool to validate existing (e.g., RTQC) flags as well as
% assign new flags or change existing flags by visual inspection of
% temperature and salinity profiles (i.e., manual DMQC). By pressing
% keys any part of a profile kan be marked visually and then assigned
% QC-flag of choice. Press ''n'' for iNstructions.
%
% [PRESqcn,TEMPqcn,PSALqcn] = check_profiles(PRES,TEMP,PSAL,...
%					PRESqco,TEMPqco,PSALqco,...
%					J,LONG,LAT,STATION_NUMBER,...
%					OPT)
%
% PRES,TEMP,PSAL = matrix input of profile data with profiles in
%		   columns, filled with NaNs for no data. Note that
%		   TEMP and PSAL can contain any two parameters you
%		   want to visually control. (PSAL can be ommited if
%		   inspecting only one parameter.)
% *qco		 = character matrices of same size as data input,
%		   containing existing flags (if any, e.g., RTQC-flags).
% J		 = indices for specific profiles (columns) in input
%		   matrices to check (default=all). 
% LONG,LAT	 = row vectors of positions of all profiles in input
%		   dataset. 
% STATION_NUMBER = row vector of integer station numbers for all
%		   profiles in input dataset (Argo cycle numbers
%		   can be input here). (Default = not used).
% OPT		 = sequence of parameter/value pairs (can be input
%		   at any point after the mandatory PRES and
%		   TEMP). Valid parameters (and their defults) are:
%   'density'	        Logical on whether to add density plot based on
%			input TEMP and PSAL (true). Use of this option
%			requires the SEAWATER toolbox.
%   'showmap'		Logical on wheter to make map on inlay (true,
%			but can be heavy on your system). Use of this
%			option requires the M_MAP toolbox.
%   'time'		Row vector of Matlab serial dates for all
%			profiles in input dataset (empty).
%   'parallelprofiles'  Struct with matrices of PRES, TEMP, and PSAL
%			from the descending/ascending from the same
%			stations/cycles.
%   'profilesmarkersize' Size of markers on profile lines in order
%			to see lone data between NaNs (4). 
%   'profileslinewidth' Linewidth of main profiles (2)
%   'cursorsize'	Size of markers for your selected region (12). 
%   'cursorthickness'	Linewidth square of markers for your selected
%			region (2).  
%   'fontsize'		Fontsize for both axis labels and flag marks (10).
%   'zoomfactor'        Fraction of range used when zooming and
%                       moving and margin when zooming in on marked
%                       data (0.3); 
%   'newpressureflagsmarkersize' Size of markers for non monotonic
%			pressure discovered by this function (6). 
%   'referencedatacolour' Colour of reference data.
%   'highlightcolour'   Colour of frame of current axes.
%   'refdatadir'	Cellstring with paths to Argo referencedata.
%                       Use of this option requires installment
%                       of the toolbox DMQC-fun and download of Argo
%                       reference data.
%   'maxprof'		Integer giving the maximum number of
%			reference profiles to show (100). If given, a
%			random selection of almost this number of
%			profiles will be shown. (A lot of reference
%			data can make things quite heavy.) 
%   'uppercut'          Number of top rows of the data matrices to
%                       exclude in the initial adjustment of axis
%                       limits to data ranges. 
%   'backgroundpalette'	Three element cell object with colour codes
%			for {figure window, axesbackground, map grid
%			and bottom contours} (Ocean Blue)
%   featuretype'        Categories of discrete sampling geometry, as
%                       given by CF-conventions. Currently available
%                       are: 'profile' (default) and 'trajectory'. 
%   'nearintime'        Number of days considered as almost
%			simultaneous with the profile in
%			question. Reference data profiles within
%			this, will be coloured dark pink.
%		   You can also edit the default values to your own
%		   liking in the beginning of this function's code.
%
% PRESqcn,TEMPqcn,PSALqcn = output character matrices with the new
%		   flagging (only) for the inspected profiles. Note
%		   that these deliberately do not carry over flags
%		   from the input, in order for the user to be able
%		   to separate newly set flags from the previously
%		   existing input flags. If only one of these are
%		   requested, only the flagging done in that panel
%		   will be delivered.
%
% This tool is originally designed for comparison and flagging of any
% pair of parameters measured in profiles, not just temperature and
% salinity. Only PRES has to be the vertical coordinate pressure (or
% depth). But you can easily input trajectory or time series
% data. The zoom and pan functions will make it practical for that as
% well. Just input as you would for a single profile.
%
% You can use TYPE PREDIT to see all instructions, keystroke menu, and
% flag list. Or simply press n, m, or f while in session.
%
% The output flag matrices are filled with space-character for data
% points that are not inspected, as well as those without data. I.e.,
% even though this is DMQC, untouched existing '0' flags will NOT be set
% to '1' in the output. The output only reflects the active changes or
% approval made by the operator while using this function. You will need
% to compare yor input *qco and the output *qcn objects yourself
% afterwards. This is done to facilitate tracking of changes when this
% function is used as part of a larger system (e.g., DMQC-fun).
%
% Example:
%	load check_profiles_sample_data
%	[Pqc_new,Tqc_new,Sqc_new]=check_profiles(P,T,S,Pqc,Tqc,Sqc);
%
% Originally this was built to work with the Argo toolbox DMQC-fun
% (https://github.com/imab4bsh/DMQC-fun.git). Use of referencedata
% provided in the Argo project requires that toolbox.
%
% REQUIRED TOOLBOXES: 
%	EVENMAT (predit, monotonic, halo, multilabel, mima, ...)
%	SEAWATER (sw_dens)
%	DMQC-FUN (inpolygon_referencedata)
% USEFUL TOOLBOX:
%	M_MAP will give you a map of the positions.
%
% See also PREDIT MONOTONIC HALO MULTILABEL INPOLYGON_REFERENCEDATA

% By Jan Even Øie Nilsen, jan.even.oeie.nilsen@hi.no.

%%%%% Set your default parameters here (or as input): %%%%%%%%%%%%%%%
par.density = true;
par.showmap = true;
par.time = [];
par.parallelprofiles = [];
par.refdatadir = '';
par.zoomfactor = 0.3;
par.profileslinewidth = 2;
par.profilesmarkersize = 8;
par.fontsize = 12;
par.cursorsize = 12;
par.cursorthickness = 2;
par.newpressureflagsmarkersize = 6;
par.referencedatacolour = [.5 .5 .5];
par.highlightcolour = [.8 .15 .15];%dark red
par.maxprof = 50; 
par.uppercut = 10;
par.backgroundpalette = {'#009dc4' '#eafaff' '#00b0dc'}; % Ocean Blue
par.featuretype = 'profile'; 
par.nearintime = 15;
par.nearcolour = [.8 .2 .5]; % Pink/magenta-ish
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check for parameter/value pairs:
vpn=fieldnames(par); % The valid parameter names
pvp=[];
for i = 1:length(varargin) % work for a list of name-value pairs
  % Check if input is character row and not part of an already identified p/v-pair:
  if ischar(varargin{i}) & isrow(varargin{i}) & ~ismember(i,pvp)
    if any(strcmp(varargin{i},vpn))		% if valid parameter name
      par.(varargin{i}) = varargin{i+1};	% write parameters to structure
      pvp=[pvp,i,i+1];	% indices for the input p/v-pairs
    % else
    %   warning(['Invalid parameter name ''',varargin{i},'''! Parameter/value pair ignored.']);
    end 
    % pvp=[pvp,i,i+1];	% indices for the input p/v-pairs
  end
end

varargin=varargin(setdiff(1:nargin-2,pvp)); % Remove parameter/value pairs from varargin
nvarargin=length(varargin);
error(nargchk(2,10+length(pvp),nargin));	% Number of arguments check

% Get the other optional inputs (and some object names)):
if  nvarargin<8, STATION_NUMBER	=[];		STATname='';	
else,		 STATION_NUMBER=varargin{8};	STATname=inputname(8+2);	end
if  nvarargin<7, LAT		=[];	else,	LAT=varargin{7};		end 
if  nvarargin<6, LONG		=[];	else,	LONG=varargin{6};		end
if  nvarargin<5, J		=[];	else,	J=varargin{5};			end
if  nvarargin<4, PSALqco	='';	else,	PSALqco=varargin{4};		end 
if  nvarargin<3, TEMPqco	='';	else,	TEMPqco=varargin{3};		end 
if  nvarargin<2, PRESqco	='';	else,	PRESqco=varargin{2};		end 
if  nvarargin<1, PSAL		=[];		PSALname='PSAL';
else,		 PSAL=varargin{1};		PSALname=inputname(1+2);	end

% Extract names of the two compulsory input objects:
PRESname=''; try PRESname=inputname(1); end; if isempty(PRESname), PRESname='PRES'; end
TEMPname=''; try TEMPname=inputname(2); end; if isempty(TEMPname), TEMPname='TEMP'; end

[m,n]=size(PRES); om=m; on=n; 

% Set defaults:
if isempty(LAT),	LAT=nan(1,n);			end
if isempty(LONG),	LONG=nan(1,n);			end
if isempty(J),		J=1:n;				end
if isempty(PSALqco),	PSALqco=repmat(' ',m,n);	end
if isempty(TEMPqco),	TEMPqco=repmat(' ',m,n);	end
if isempty(PRESqco),	PRESqco=repmat(' ',m,n);	end
if isempty(PSAL),	PSAL=nan(m,n); 
			PSALqco=repmat(' ',m,n);
			par.density=false;		end
			
% Check geometry of inputs:
if size(STATION_NUMBER)~=[1 n] & ~isempty(STATION_NUMBER) 
  error('Size of STATION_NUMBER input must match number of columns in input data matrices!'); 
end
if ~isequal(size(LONG),size(LAT)) | ~isequal(size(LAT),size(STATION_NUMBER)) & ~isempty(STATION_NUMBER) 
  error('Input LONG, LAT, and STATION_NUMBER must be equal sized row vectors (1xn)!');
end
if ~isequal(size(PRES),size(TEMP),size(PSAL),size(PRESqco),size(TEMPqco),size(PSALqco))
  error('Input data (and flag) matrices must be of same size!');
end
if m==1						% For timeseries and trajectories, flip everything
  PRES=PRES(:); TEMP=TEMP(:); PSAL=PSAL(:); 
  PRESqco=PRESqco(:); TEMPqco=TEMPqco(:); PSALqco=PSALqco(:); 
  m=on; n=om; J=1;
  if ~contains(par.featuretype,{'timeSeries','trajectory'})
    par.featuretype = 'trajectory'; % Default for 1xn input
    disp(['check_profiles: Assuming the 1xn input is of featuretype ',par.featuretype,'.'])
  end
end
if ~isempty(par.parallelprofiles)		% Parallel profiles
  if ~isequal(size(par.parallelprofiles.PRES),size(par.parallelprofiles.TEMP),size(par.parallelprofiles.PSAL))
    warning('Input data and parallel-profile matrices does not have the same number of columns!');
    par.parallelprofiles=[];
  end
end
% Valid featuretype strings:
% point timeSeries trajectory profile timeSeriesProfile trajectoryProfile


% Init the new flag matrices to be filled here:
[PRESqcn,TEMPqcn,PSALqcn] = deal(repmat(' ',m,n)); 

% Data for potential density as additional plot:
if par.density
  DENS = sw_pden(PSAL,TEMP,PRES,0);	
  if ~isempty(par.parallelprofiles)		% Parallel profiles
    par.parallelprofiles.DENS = sw_pden(par.parallelprofiles.PSAL,par.parallelprofiles.TEMP,par.parallelprofiles.PRES,0);	
  end
  % If realistic values, density is in use and plot shall be made:
  if 985 < min(DENS,[],'all') & max(DENS,[],'all') < 1040
    DENSqco = repmat(' ',m,n);
    TEMPqco~=DENSqco; DENSqco(ans)=TEMPqco(ans);
    PSALqco~=DENSqco; DENSqco(ans)=PSALqco(ans);
  else
    par.density=false;
    clear DENS DENSqco
    DENSqco = repmat(' ',m,n); % Create and use this anyway
  end
  % Any flagging in DENS graph will affect both TEMP and PSAL, but
  % mostly just for viewing.
else
  DENSqco = repmat(' ',m,n); % Create and use this anyway
end

% Init empty handles for the main lines where flags are stored:
[hP,hT,hS,hD,hF,skipped,omitted] = deal([]);				
% This is likely superfluous for the handles, but part of debugging
% w.r.t. the final writing to the output.  In any case, we do not assign
% anything to these now, as operator can stop any time she or he likes.

N=length(J);
for j=1:N	% Loop columns to check 

  % Init/reset the _temporary_ handles used within this loop:
  [hrT,hrS,hrD, hnT,hnS,hnD, hppT,hppS,hppD, hmP,hmT,hmS,hmD, ...
   hPiT,hPiS,hPiD, hPnP,hPnT,hPnS,hPnD, ...
   hPx,hTx,hSx,hDx, aP,aT,aS,aD] = deal([]);				

  % Main info for header in figure:
  header=['Column ',int2str(J(j))];
  if ~isempty(STATION_NUMBER), header=[header,'   ',STATname,' ',int2str(STATION_NUMBER(J(j)))]; end
  if ~isempty(par.time), header=[header,'   ',datestr(par.time(J(j)))]; end

  % Check for COMPLETELY empty station:
  if all(isnan(PRES(:,J(j)))) | all(isnan(TEMP(:,J(j)))) & all(isnan(PSAL(:,J(j)))) 
    header=[header,' has no data!']; disp(['check_profiles: ',header]);
    continue
  end
  
  % My own pressure test:
  [~,ans]=monotonic(PRES(:,J(j)));	
  iPn=find(ans);			% Indices for new bad flagged pressure values
  %PRESqco(iPn,J(j))='4';		% No, DO NOT add these to old flags 

  % Indices to initial markers (all not good flagged values):
  iP=find(PRESqco(:,J(j))~='1' & PRESqco(:,J(j))~=' ');
  iT=find(TEMPqco(:,J(j))~='1' & TEMPqco(:,J(j))~=' ');
  iS=find(PSALqco(:,J(j))~='1' & PSALqco(:,J(j))~=' ');
  % Indices for pressure flags ignoring the '2' flags on deep pressures:
  iP2=find(PRESqco(:,J(j))~='1' & PRESqco(:,J(j))~='2' & PRESqco(:,J(j))~=' ');
  % iD for DENS is set below (if necessary).
  
  % Find indices to use below: 
  jjj=J(j)+[-3:3];					% For float positions
  jj=jjj([1:3 5:7]);					% For neighbouring profiles only
  jjj=jjj(0<jjj&jjj<=n);				% Make sure not out of range
  jj=jj(0<jj&jj<=n);					% Make sure not out of range
  ~isnan(LONG(jjj))&~isnan(LAT(jjj)); jjj=jjj(ans);	% Avoid NaNs ([] POSqco is not applied yet)
  
  % Extract reference data:
  if ~isempty(par.refdatadir) & ~all(isnan(LONG(jjj))) & ~all(isnan(LAT(jjj)))	% If any positions
    if diff(mima(LONG(jjj)))<0.6 & diff(mima(LAT(jjj)))<0.4 % Make sure not too small area of group
      [LO,LA]=halo(LONG(jjj),LAT(jjj),1.2,0.7);		% Find envelope
    elseif isscalar(LONG),	
      [LO,LA]=halo(LONG(jjj),LAT(jjj),.3,.2);		% Find envelope
    else		
      [LO,LA]=halo(LONG(jjj),LAT(jjj),.3);		% Find envelope
    end
    % [] time always given?
    [pres,temp,sal,long,lat,~,rdt,~,dmon,mons,yrs]=inpolygon_referencedata(LO,LA,par.refdatadir,par.maxprof,par.time(J(j)));	% Find refdata in envelope
  else
    [LO,LA,pres,temp,sal,dens,long,lat,rdt,dmon,mons,yrs]=deal([]);		% Otherwise empty
  end
  figure; hF(j)=gcf;				% FIGURE
  set(hF(j),'position',get(0,'screensize'),'color',par.backgroundpalette{1}, ...
	    'name',['check_profiles: Profile ',int2str(j)], ...
	    'Tag','check_profiles'); clf;
  % Add the original flags to parameters (in order to use esc):
  par=setfield(par,'oldflags',[PRESqco(:,J(j)),TEMPqco(:,J(j)),PSALqco(:,J(j)),DENSqco(:,J(j))]);
  set(hF(j),'Userdata',par);			% Store parameters in figure's userdata.

  aP=subplot(4,3,[10 11 12]);			% LOWER PANEL
  ii=1:length(PRES(:,J(j)));			% Coordinate for the pressure
  hmP=plot(PRES(:,J(j)),ii);			% Visualisation of the profile in question
  hP(j)=line(PRES(:,J(j)),ii);			% Plot the profile in question
  set(hP(j),'markerindices',iP,'UserData',PRESqco(:,J(j))); % Show any flagged points and store flags in object
  hPx=text(PRES(iP,J(j)),ii(iP),PRESqco(iP,J(j))); % Add flags as text
  % Plot data with new flagged pressure (just to mark it once):
  if any(iPn), hPnP=line(PRES(iPn,J(j)),ii(iPn)); 
    set(hPnP,'color','c','marker','o','markersize',par.newpressureflagsmarkersize,'linestyle','none');
  end
  axis ij; xlabel(PRESname,'interpreter','none'); ylabel index; title(PRESname,'interpreter','none'); grid;  % Cosmetics
 
  aT=subplot(4,3,[1 4 7]);			% LEFT PANEL
  hrT=plot(temp,pres);				% Reference profiles
  hnT=line(TEMP(:,jj),PRES(:,jj));		% Neighbouring profiles
  if ~isempty(par.parallelprofiles)		% Parallel profile (if any)
    if J(j)+1<=size(par.parallelprofiles.PRES,2)% including next cycle
      hppT=line(par.parallelprofiles.TEMP(:,J(j)+[0:1]),par.parallelprofiles.PRES(:,J(j)+[0:1]));	
    elseif J(j)<=size(par.parallelprofiles.PRES,2)
      hppT=line(par.parallelprofiles.TEMP(:,J(j)),par.parallelprofiles.PRES(:,J(j)));		
    end
  end
  hmT=line(TEMP(:,J(j)),PRES(:,J(j)));		% Visualisation of the profile in question
  hT(j)=line(TEMP(:,J(j)),PRES(:,J(j)));	% The profile in question
  set(hT(j),'markerindices',iT,'UserData',TEMPqco(:,J(j))); % Show any flagged points and store flags in object
  hTx=text(TEMP(iT,J(j)),PRES(iT,J(j)),TEMPqco(iT,J(j))); % Add flags as text
  hPiT=line(TEMP(:,J(j)),PRES(:,J(j)));		% Invisible line for pressure markers on the profile in question
  set(hPiT,'markerindices',iP2);		% but showing pressure-flagged points
  % Plot data with new flagged pressure (just to mark it once):
  if any(iPn), hPnT=line(TEMP(iPn,J(j)),PRES(iPn,J(j))); 
    set(hPnT,'color','c','marker','o','markersize',par.newpressureflagsmarkersize,'linestyle','none');
  end
  axis ij; xlabel(TEMPname,'interpreter','none'); ylabel(PRESname,'interpreter','none'); title(TEMPname,'interpreter','none'); grid;  % Cosmetics
  
  aS=subplot(4,3,[2 5 8]);			% MIDDLE PANEL		 
  hrS=plot(sal,pres);				% Reference profiles	 
  hnS=line(PSAL(:,jj),PRES(:,jj));		% Neighbouring profiles	 
  if ~isempty(par.parallelprofiles)		% Parallel profile (if any)
    if J(j)+1<=size(par.parallelprofiles.PRES,2)% including next cycle
      hppS=line(par.parallelprofiles.PSAL(:,J(j)+[0:1]),par.parallelprofiles.PRES(:,J(j)+[0:1]));	
    elseif J(j)<=size(par.parallelprofiles.PRES,2)
      hppS=line(par.parallelprofiles.PSAL(:,J(j)),par.parallelprofiles.PRES(:,J(j)));		
    end
  end
  hmS=line(PSAL(:,J(j)),PRES(:,J(j)));		% Visualisation of the profile in question
  hS(j)=line(PSAL(:,J(j)),PRES(:,J(j)));	% The profile in question
  set(hS(j),'markerindices',iS,'UserData',PSALqco(:,J(j))); % Show any flagged points and store flags in object
  hSx=text(PSAL(iS,J(j)),PRES(iS,J(j)),PSALqco(iS,J(j)));  % Add flags as text
  hPiS=line(PSAL(:,J(j)),PRES(:,J(j)));		% Invisible line for pressure markers on the profile in question
  set(hPiS,'markerindices',iP2);		% but showing pressure-flagged points
  % Plot data with new flagged pressure (just to mark it once):
  if any(iPn), hPnS=line(PSAL(iPn,J(j)),PRES(iPn,J(j))); 
    set(hPnS,'color','c','marker','o','markersize',par.newpressureflagsmarkersize,'linestyle','none'); 
  end
  axis ij; xlabel(PSALname,'interpreter','none'); ylabel(PRESname,'interpreter','none'); title(PSALname,'interpreter','none'); grid;  % Cosmetics

  if par.density
    aD=subplot(4,3,[3 6 9]);			% RIGHT PANEL (AUXILLARY GRAPH)
    dens = sw_pden(sal,temp,pres,0);
    hrD=plot(dens,pres);			% Reference profiles	 
    hnD=line(DENS(:,jj),PRES(:,jj));		% Neighbouring profiles	 
  if ~isempty(par.parallelprofiles)		% Parallel profile (if any)
    if J(j)+1<=size(par.parallelprofiles.PRES,2)% including next cycle
      hppD=line(par.parallelprofiles.DENS(:,J(j)+[0:1]),par.parallelprofiles.PRES(:,J(j)+[0:1]));	
    elseif J(j)<=size(par.parallelprofiles.PRES,2)
      hppD=line(par.parallelprofiles.DENS(:,J(j)),par.parallelprofiles.PRES(:,J(j)));		
    end
  end
    hmD=line(DENS(:,J(j)),PRES(:,J(j)));	% Visualisation of the profile in question
    hD(j)=line(DENS(:,J(j)),PRES(:,J(j)));	% The profile in question
    iD=find(DENSqco(:,J(j))~='1' & DENSqco(:,J(j))~=' '); % Indices for all not good flagged values
    set(hD(j),'markerindices',iD,'UserData',DENSqco(:,J(j))); % Show any flagged points and store flags in object
    hDx=text(DENS(iD,J(j)),PRES(iD,J(j)),DENSqco(iD,J(j)));  % Add flags as text
    hPiD=line(DENS(:,J(j)),PRES(:,J(j)));	% Invisible line for pressure markers on the profile in question
    set(hPiD,'markerindices',iP2);		% but showing pressure-flagged points
    % Plot data with new flagged pressure (just to mark it once):
    if any(iPn), hPnD=line(DENS(iPn,J(j)),PRES(iPn,J(j))); 
      set(hPnD,'color','c','marker','o','markersize',par.newpressureflagsmarkersize,'linestyle','none'); 
    end
    axis ij; xlabel('Potential density'); ylabel(PRESname,'interpreter','none'); title('Potential density'); grid;  % Cosmetics
    set(hD(j),'color','r','linestyle','none','Marker','s','MarkerEdgecolor','m',...
	      'markersize',par.cursorsize,'linewidth',par.cursorthickness,'Tag','check_profiles_line'); % The marked region
  end

  % Place and plot inlay 'map' showing how positions relate to each other: % INLAY
  if ~isempty(LONG(jjj)) & ~isempty(LAT(jjj))
    get(aT,'position'); 
    aM=axes('position',[ans(1)+ans(3)-ans(3)/2-.02 ans(2)+.02 ans(3)/2 ans(4)/2]);
    if exist('m_proj') & par.showmap
      m_proj('Lambert','lon',mima(LONG(jjj))+[-4 4],'lat',mima(LAT(jjj))+[-2 2]);
      m_grid('color',par.backgroundpalette{3},'backgroundcolor',par.backgroundpalette{2}); 
      m_coast; 
      m_elev('contour',[-5000:500:0],'color',par.backgroundpalette{3});
      m_plot(LO,LA,'color',par.referencedatacolour);				% Plot envelope
      hPOS=m_line(LONG(jjj),LAT(jjj)); set(hPOS,'marker','.','color','b');	% Positions of neighbouring profiles
      hePOS=m_line(LONG(J(j)),LAT(J(j))); set(hePOS,'marker','s','color','r');	% Position of the profile in question
    else
      plot(LO,LA,'color',par.referencedatacolour);				% Plot envelope
      hPOS=line(LONG(jjj),LAT(jjj)); set(hPOS,'marker','.','color','b');	% Positions of neighbouring profiles
      hePOS=line(LONG(J(j)),LAT(J(j))); set(hePOS,'marker','s','color','r');	% Position of the profile in question
      set(aM,'visible','off');							% Hide axes
    end
    if ~isempty(long)
      dtnote=['Reference data are from months ',zipnumstr(mons),' in years ',zipnumstr(yrs)];
      multilabel(dtnote,'b');							% Info about seasonality and period of refdata
    end
    set(aM,'Userdata','check_profiles_map');					% Identifier for predit
    set(aM,'PickableParts','none');						% Avoid this axis to become current
  end

  % SETTINGS ON ALL LINES AND TEXT, LABELS ETC.:
  set([hppT;hppS;hppD],'color','c','marker','.','markersize',par.profilesmarkersize);		% Same cycle Parallel profile
  if length(hppS)==2, set([hppT(2);hppS(2);hppD(2)],'color','g'); end				% Next Parallel profile
  set([hnT;hnS;hnD],'color','b','marker','.','markersize',par.profilesmarkersize);		% Neighbouring profiles
  set([hrT;hrS;hrD],'color',par.referencedatacolour);						% Reference profiles
  % Monthly color and thickness gradient in refdata based on time difference in year:
  for i=2:11, dmon==i; set([hrT(ans),hrS(ans),hrD(ans)],'color',brighten(par.referencedatacolour,-.2+.1*i),'linewidth',1.5-.12*i); end
  for i=0:1,  dmon==i; set([hrT(ans),hrS(ans),hrD(ans)],'color',brighten(par.referencedatacolour+[0 .1 0],-.2+.1*i),'linewidth',1.5-.12*i); end
  near=find(abs(rdt)<par.nearintime); 
  if any(near)
    set([hrT(near),hrS(near),hrD(near)],'color',par.nearcolour,'linewidth',par.profileslinewidth);% Highlight if actually the same month
    set(gcf,'currentaxes',aM);									% For adding near points to map	
    clear hnetx
    for i=1:length(near)									% Mark the near profiles with days difference
      neartxt=[int2str(round(rdt(near(i)))),'/',int2str(round(sw_dist([LAT(J(j)),lat(near(i))],[LONG(J(j)),long(near(i))],'km')))];
      xt=get(hrT(near(i)),'xdata'); yt=get(hrT(near(i)),'ydata');  find(~isnan(xt)&~isnan(yt));
      hnetx(i,1)=text(aT,xt(ans(1)),yt(ans(1)),neartxt);
      xt=get(hrS(near(i)),'xdata'); yt=get(hrS(near(i)),'ydata');  find(~isnan(xt)&~isnan(yt));
      hnetx(i,2)=text(aS,xt(ans(1)),yt(ans(1)),neartxt);
      xt=get(hrD(near(i)),'xdata'); yt=get(hrD(near(i)),'ydata');  find(~isnan(xt)&~isnan(yt));
      hnetx(i,3)=text(aD,xt(ans(1)),yt(ans(1)),neartxt);
      hnetx(i,4)=m_text(long(near(i)),lat(near(i)),int2str(rdt(near(i))));
    end
    set(hnetx,'clipping','off','color',par.nearcolour,'VerticalAlignment','bottom','horizontalalignment','center');
    set(hnetx(:,4),'VerticalAlignment','middle');
  end
  set([hrT;hrS;hrD; hnT;hnS;hnD; hmP;hmT;hmS;hmD; hppT;hppS;hppD],'handlevisibility','off');	% All visualisation lines inactive
  set([hmP;hmT;hmS;hmD],'color','r','linestyle','-','linewidth',par.profileslinewidth,...
		    'Marker','.','markersize',par.profilesmarkersize);				% Main visualisation line
  set([hP(j);hT(j);hS(j)],'linestyle','none','Marker','s','MarkerEdgecolor','m','markersize',par.cursorsize,...
		    'linewidth',par.cursorthickness,'Tag','check_profiles_line');		% The cursors of marked region
  set([hP(j)],'MarkerEdgecolor',[0 .6 0]);							% Cursor in pressure graph always green
  set([hPx;hTx;hSx;hDx],'color','k','horizontalalignment','center',...
		    'clipping','on','fontsize',par.fontsize,'Tag','check_profiles_text');	% Flags shown as text
  set([hPiT,hPiS,hPiD],'linestyle','none','marker','s','MarkerEdgeColor',[0 .6 0],...
		    'markersize',par.cursorsize+4,'linewidth',round(par.cursorthickness/2),'Tag','check_profiles_pline'); % Pressure marks on the other plots
  mima(get([hT(j);hS(j);hnT;hnS],'ydata')); set([aT,aS,aD],'ylim',ans+[-10 10]);		% Same pressure limits on all
  set(aP,'xlim',ans+[-10 10]);									% and on pressure's y-axis
  set([aP,aT,aS,aD],'color',par.backgroundpalette{2},'fontsize',par.fontsize);			% Fontsize for both axis labels and flag marks
  mima(find(~isnan(get(hP(j),'xdata')))); set(aP,'ylim',ans+[-5 5]);				% Index limit to existing data only
  mima(get([hT(j);hppT;hnT;hrT],'xdata')); set(aT,'xlim',ans+[-.1 .1]);		% Initial TEMP zoom.
  mima(get([hS(j);hppS;hnS;hrS],'xdata')); set(aS,'xlim',ans+[-.01 .01]);	% Initial PSAL zoom.  
  set(aP,'userdata',[xlim(aP) ylim(aP)],'Tag','1');				% Store original limits, 
  set(aT,'userdata',[xlim(aT) ylim(aT)],'Tag','2');				% and tag axes.
  set(aS,'userdata',[xlim(aS) ylim(aS)],'Tag','3');  
  if ~isempty(aD), 
    mima(get([hD(j);hppD;hnD;hrD],'xdata')); set(aD,'xlim',ans+[-.01 .01]);	% Initial DENS zoom.
    set(aD,'userdata',[xlim(aD) ylim(aD)],'Tag','4');				% Store zoom, and tag axes. 
  end
  htxt=['Press ''n'' for iNstructions']; ma=multilabel({header;htxt},'t');	% The main title
  set(ma(2),'fontweight','bold','fontsize',16,'interpreter','none');
  
  % % If only one parameter input, delete the axes:
  % if all(isnan(TEMP(:,J(j)))), delete(aT); aT=[]; end
  % if all(isnan(PSAL(:,J(j)))), delete(aS); aS=[]; end
  % if all(isnan(TEMP(:,J(j)))) & all(isnan(PSAL(:,J(j)))), delete(aD); aD=[]; end
  % If only one parameter input, hide the axes:
  set(gcf,'currentaxes',aS);		% Middle panel is current by default
  if all(isnan(TEMP(:,J(j)))) | ...
     all(isnan(PSAL(:,J(j)))), delete([hrD,hnD]); set(aD,'visible','off'); end
  if all(isnan(PSAL(:,J(j)))), delete([hrS,hnS]); set(aS,'visible','off'); set(gcf,'currentaxes',aT); end
  if all(isnan(TEMP(:,J(j)))), delete([hrT,hnT]); set(aT,'visible','off'); set(gcf,'currentaxes',aS); end

  % Accomodate for missing data in one or more parameters
  %set(gcf,'currentaxes',aS);		% Middle panel is current by default
  %if ~any(get(hD(j),'xdata')), set(gcf,'currentaxes',aS); end % set(aD(j),'handlevisibility','off'); 
  %if ~any(get(hS(j),'xdata')), set(gcf,'currentaxes',aT); end % set(aS(j),'handlevisibility','off'); 
  %if ~any(get(hT(j),'xdata')), set(gcf,'currentaxes',aS); end % set(aT(j),'handlevisibility','off'); 
  %if ~any(get(hP(j),'xdata')),                            end % set(aP(j),'handlevisibility','off'); 
  set(gca,'XColor',par.highlightcolour,'YColor',par.highlightcolour);	% Highlight current axis initially

  % The DMQC session:
  %set(gcf,'currentaxes',aT);						% Left panel is current, but set
  %if any(hS(j)), set(gcf,'currentaxes',aS); end			% middle panel as current (if profile exist)
  set(gcf,'WindowKeyPressFcn','predit',...				% PREDIT as keypressfunction
	  'WindowButtonDownFcn','predit(true)');			% Only highlight when button selecting
  %%set(gcf,'KeyPressFcn','predit',...				% PREDIT as keypressfunction
  %%	  'ButtonDownFcn','predit(true)');			% Only highlight when button selecting
  %set(gca,'XColor',par.highlightcolour,'YColor',par.highlightcolour);	% Highlight current axis initially
  waitfor(gcf,'name');%,{'checked','final check'}); any cahnge			% Wait for signal that currrent profile is checked
  if contains(get(gcf,'name'),'last checked'), break; end			% Make it possible to end session at any point
  %if strcmp(get(gcf,'name'),'final check'), break; end			% Make it possible to end session at any point
  if j==N,     
    helpdlg(['This was the last profile.',... 
	     ' After closing this dialog you can edit the flags in all open figures',...
	     ' and then press enter to end session.',...
	     ' Do not close any figure windows before ending session!'],...
	    'The end!');
  end
end

% Make sure operator can check all figures before ending session, also
% after finished with all profiles:
waitfor(0,'Tag','end check');
%waitfor(gcf,'name','final check');

% You might have stopped in the middle of the checking. Then the rest of
% the columns in the output flag matrices will be blank:
%omitted=[omitted,j+1:N];
% Also if you did not start with the first column, there are omitted
% columns before. 
omitted=[1:J(1)-1,J(j)+1:n];

% The number of profiles (of the J profiles) that has been checked:
N=j; 

% Now assign all the userdata from the plotted lines of all checked
% figures to the output flag matrices:
for j=1:N 	% Loop checked columns and figures 
  % ASSIGN ANY NEW OR REVERSED FLAGS. i.e. extract from the lines'
  % userdata, or for closed windows assign the old input flags:
  % (Pressure is not flagged yet)
  if isgraphics(hP(j)) & any(hP(j)), PRESqcn(:,J(j)) = get(hP(j),'UserData'); else, PRESqcn(:,J(j)) = PRESqco(:,J(j)); end
  if isgraphics(hT(j)) & any(hT(j)), TEMPqcn(:,J(j)) = get(hT(j),'UserData'); else, TEMPqcn(:,J(j)) = TEMPqco(:,J(j)); end
  if isgraphics(hS(j)) & any(hS(j)), PSALqcn(:,J(j)) = get(hS(j),'UserData'); else, PSALqcn(:,J(j)) = PSALqco(:,J(j)); end
  % j
  % hF(j)
  % isgraphics(hF(j))
  % if ~isgraphics(hF(j))
  %   skipped=[skipped,j]
  % end
  % PRESqcn(:,J(j)) = get(hP(j),'UserData');
  % TEMPqcn(:,J(j)) = get(hT(j),'UserData');
  % if ~isempty(aS), PSALqcn(:,J(j)) = get(hS(j),'UserData'); end
  % % Assign '1' to any '0', since this is DMQC:
  % TEMPqcn(TEMPqcn=='0')='1';
  % PSALqcn(PSALqcn=='0')='1';
end

% Messages about skipping or stopping short:
% When figures are closed, next figure gets same number.
[~,gi] = groups(hF);		% Find groups of same number.
if ~isempty(gi)
  hF(gi(2,:))=0;		% Set endpoints of groups to zero ...
  %[~,~,gs] = groups(hF);	% ... and find groups again.
  [~,~,gs] = groups([-1:-1:-J(1)+1,hF]); % ... and find groups again.
  % The little trick by prepending a row of a negative number
  % sequence makes gs reflect columns in the matrix instead of
  % just which windows were closed.
  disp(['check_profiles: You closed the figures for columns ',gs,' while checking. These are thus' ...
	' considered ''good as they are'' and output flags' ...
	' for these columns are the same as input flags.']);
end
if ~isempty(omitted)
  disp(['check_profiles: You did not check columns ',zipnumstr(omitted),'.',...
	' These are considered not checked and thus output flags' ...
	' for these columns are blank.']);
end

close(findobj('-regexp','name','check_profiles:')); % Close _after_ all data has been extracted! 

% Remove those flags the function made on NaN data:
PRESqcn(isnan(PRES))=' ';
TEMPqcn(isnan(TEMP))=' ';
PSALqcn(isnan(PSAL))=' ';

set(0,'Tag','');

% Shape output according to input, regardless of featuretype:
PRESqcn=reshape(PRESqcn,om,on);
TEMPqcn=reshape(TEMPqcn,om,on);
PSALqcn=reshape(PSALqcn,om,on);
