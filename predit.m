function predit(mousemode)
% PREDIT  Profile editing by keypress.
% The keypressfunction used by CHECK_PROFILES.
%
% mousemode = logical whether to treat buttondown actions or not
%	      (default = false = treat keypress)
%
% No output.
%
% Use TYPE PREDIT to see the instructions and lists in the code below.

% ----- Instructions -------------------------------------------------
instructions=[...
    "Red line is the profile in question.";
    "Numbers printed on red line are its flags (except qc='1' good).";
    "Magenta squares marks your selection (or initially, previously flagged points)."; 
    "Blue lines are preceeding and subsequent profiles in input matrices.";
    "Cyan and green lines are oposite-direction profiles from the same and next station/cycle, respectively (if provided).";
    "Grey lines are reference data (if provided).";
    "Green lines are reference data in same or neighbouring month of year (i.e., season; if provided).";
    "Reference data lines are thinner the more off-season they are";
    "Green squares are points with PRES flagged qc='4'";
    "Any cyan circles are nonmonotonic pressure points found now."; 
    "Inlay shows geometry of positions with polygon for reference data selection in grey (if any).";
    "There are keystrokes for different types of zooming.";
    "You can also press window-control buttons to zoom etc., but turn them off before using any keystrokes.";
    "Mouse-click anywhere in axes to select parameter to operate on.";
    "The current axes are highlighted in dark red.";
    "Press space-bar to approve existing flags in all parameters and continue.";
    "Press <enter> to end session and produce output.";
    "Press 'm' for Menu of all available keystrokes."];

% ----- The keys and their meaning: ----------------------------------
helptext=[...
    "MARKING:"
    "a - Mark full (non-nan) profile.";
    "s - Mark a small group in middle of visible profile.";
    "e - Mark a small group in upper half of visible profile.";
    "d - Mark a small group in lower half of visible profile.";
    "y - Extend marked region by 10 points from the top.";	 
    "u - Extend marked region by 1 point from the top.";	 
    "i - Reduce marked region by 1 point at the top.";	 
    "o - Reduce marked region by 10 points at the top.";	 
    "h - Reduce marked region by 10 points at the bottom.";	 
    "j - Reduce marked region by 1 point at the bottom.";	 
    "k - Extend marked region by 1 point from the bottom.";
    "l - Extend marked region by 10 points from the bottom.";	 
    ""
    "ZOOMING:"
    "<uparrow> - zoom in on marked region.";
    "<downarrow> - zoom out to original axis limits.";
    "<rightarrow> - zoom in.";
    "<leftarrow> - zoom out.";
    "c - Center on visible profile and zoom x-axis in.";
    "x - Center on visible profile and zoom x-axis out.";
    "b - Center on visible profile and zoom y-axis in.";
    "v - Center on visible profile and zoom y-axis out.";
    ""
    "MOVING:"
    "t - Move view up.";
    "g - Move view down.";
    ""
    "FLAGGING:"
    "1-9 - Flag marked points '1'-'9'."; 
    "z - Flag marked points '0' (zero). Not recommended!"; 
    "q - Toggle QC-flags shown as text ('1' will not be shown).";     
    ""
    "MISC::"
    "p - Toggle Position plot/map visibility.";     
    "m - Display keystroke Menu.";
    "n - Display iNstructions and legend.";
    "f - Display Flag list.";
    "<escape> - Revert to original flags.";
    "<space> - Approve station (column) and continue to next.";
    "<return> - End session."];

% ----- The Argo flag scale: -----------------------------------------
argoflags=[ ...
'0', "No QC is performed", ...
     "No QC is performed.", ...
     "No QC is performed.";...
'1', "Good data." , ...
     "Good data. All Argo real-time QC tests passed. These measurements are good within the limits of the Argo real-time QC tests."  , ...
     "Good data. No adjustment is needed, or the adjusted value is statistically consistent with good quality reference data. An error estimate is supplied.";... 
'2', "Probably good data"  , ...
     "Probably good data. These measurements are to be used with caution."  , ...
     "Probably good data. Delayed mode evaluation is based on insufficient information. An error estimate is supplied.";...
'3', "Probably bad data that are potentially adjustable", ...
     "Probably bad data. These measurements are not to be used without scientific adjustment, e.g. data affected by sensor drift but may be adjusted in delayed-mode.", ...
     "Probably bad data. An adjustment may (or may not) have been applied, but the value may still be bad. An error estimate is supplied.";...
'4', "Bad data", ...
     "Bad data. These measurements are not to be used. A flag '4' indicates that a relevant realtime qc test has failed. A flag '4' may also be assigned for bad measurements that are known to be not adjustable, e.g. due to sensor failure.", ...
     "Bad data. Not adjustable. Adjusted data are replaced by FillValue.";...
'5', "Value changed", ...
     "Value changed", ...
     "Value changed";...
'6', "Not used", ...
     "Not used", ...
     "Not used"; ...
'7', "Not used", ...
     "Not used", ...
     "Not used";...
'8', "Estimated value", ... 
     "Estimated value (interpolated, extrapolated, or other estimation)", ...
     "Estimated value (interpolated, extrapolated, or other estimation)"; ...
'9', "Missing value", ...
     "Missing value. Data parameter will record FillValue.", ...
     "Missing value. Data parameter will record FillValue."; ...
' ', "FillValue", ...
     "Empty space in netcdf file.", ...
     "Empty space in netcdf file."];


% ----- The function code (ignore): ----------------------------------

if nargin<1 | isempty(mousemode), mousemode=false; end

alx=findobj(gcf,'type','axes');			% All axes in figure
[a,ia]=sort(get(alx,'Tag')); alx=alx(ia);	% Sort axes by tag
alx=alx(contains(a,{'1','2','3','4'}));		% Axes marked as profile plots
nalx=length(alx);				% Number of profile plot axes
par=get(gcf,'Userdata');			% Parameters from CHECK_PROFILES
h=findobj(gca,'Tag','check_profiles_line');	% current parameter line
fl=get(h,'Userdata');				% Flags stored in current line
hx=findobj(gca,'Tag','check_profiles_text');	% current parameter flags
hPi=findobj(gcf,'Tag','check_profiles_pline');	% pressure-flag marks on parameter lines
x=get(h,'Xdata'); y=get(h,'Ydata');		% current parameter data
atyp=str2num(get(gca,'Tag'));			% current parameter type
btyp=setdiff([1:nalx],atyp);			% other parameter types
for i=1:nalx-1
  axb(i)=findobj(gcf,'Tag',num2str(btyp(i)));		% other parameters' axes
  hb(i)=findobj(axb(i),'Tag','check_profiles_line');	% other parameters' lines
  xb{i}=get(hb(i),'Xdata'); yb{i}=get(hb(i),'Ydata');	% other parameters' data
end

if mousemode
  set(gca,'XColor',par.highlightcolour,'YColor',par.highlightcolour);	% Highlight current axis
  set(axb,'XColor',[.15 .15 .15],'YColor',[.15 .15 .15]);		% Un-highlight other axes
  return
end

ham=findobj(gcf,'Userdata','check_profiles_map');	% map axis handle
amap=get(ham,'children');				% map objects handles
if isempty(hx), tx=false; else tx=true; end
newflags=false;

mi=get(h,'MarkerIndices');
find(~isnan(x)); 
if ~isempty(ans)
  n1=ans(1); n2=ans(end); % Start and end index for non-nan data
else
  return
end
if isempty(mi)	% Could be no flags>1 on profile
  mi=ceil((n2-n1)/2)+[-1:1]; % Just assign (but not mark) a point in the middle
end
it=double(mi(1));
ib=double(mi(end));

key=get(gcf,'Currentkey');
switch key
 case 'y', it=it-10;	
 case 'u', it=it-1;	
 case 'i', it=it+1;	
 case 'o', it=it+10;	
 case 'h', ib=ib-10;	
 case 'j', ib=ib-1;	
 case 'k', ib=ib+1;	
 case 'l', ib=ib+10;	
 case 'a', it=n1; ib=n2;
 case {'e','s','d'}				% ADD MARKERS
  nxl=get(gca,'xlim'); nyl=get(gca,'ylim');	% Get current ranges
  nna=find(~isnan(x));				% Non-nan data only
  ii=nna(nxl(1)<x(nna)&x(nna)<nxl(2) & nyl(1)<y(nna)&y(nna)<nyl(2)); % Check for data in visible range 
  switch key
   case 'e', fr=1/4;	% upper half
   case 's', fr=1/2;	% middle
   case 'd', fr=3/4;	% lower half
  end
  [it,ib]=deal(ii(1)+ceil((ii(end)-ii(1))*fr));	% Set top and bottom same
  it=it-2; ib=ib+2;				% Expand to a group 
  mi=[it:ib];					% Set markers to group
 case 'leftarrow'
  % Zoom Out by same factor out on both axes in all (keeping same in PRES)
  get(gca,'xlim'); nxl=ans+diff(ans).*[-1 1]*par.zoomfactor; set(gca,'xlim',nxl); 
  get(gca,'ylim'); nyl=ans+diff(ans).*[-1 1]*par.zoomfactor; set(gca,'ylim',nyl);
  for i=1:nalx-1	% The other plots
    if atyp==1 		% When zooming in pressure plot, change other plots like this:
      set(axb(i),'ylim',nxl);
      get(axb(i),'xlim'); set(axb(i),'xlim',ans+diff(ans).*[-1 1]*par.zoomfactor); % zoom out by same factor 
    else		% When zooming in other plots
      if btyp(i)==1	% change pressure plot like this:
	set(axb(i),'xlim',nyl);
	get(axb(i),'ylim'); set(axb(i),'ylim',ans+diff(ans).*[-1 1]*par.zoomfactor); % zoom out by same factor 
      else		% and change other plots like this:
	set(axb(i),'ylim',nyl);
	get(axb(i),'xlim'); set(axb(i),'xlim',ans+diff(ans).*[-1 1]*par.zoomfactor); % zoom out by same factor 
      end
    end
  end
  set(amap,'visible','off');
 case 'rightarrow'
  % Zoom In by same factor in on both axes in all (keeping same in PRES)
  get(gca,'xlim'); nxl=ans+diff(ans).*[1 -1]*par.zoomfactor; set(gca,'xlim',nxl); 
  get(gca,'ylim'); nyl=ans+diff(ans).*[1 -1]*par.zoomfactor; set(gca,'ylim',nyl);
  for i=1:nalx-1	% The other plots
    if atyp==1 		% When zooming in pressure plot, change other plots like this:
      set(axb(i),'ylim',nxl);
      get(axb(i),'xlim'); set(axb(i),'xlim',ans+diff(ans).*[1 -1]*par.zoomfactor); % zoom in by same factor 
    else		% When zooming in other plots
      if btyp(i)==1	% change pressure plot like this:
	set(axb(i),'xlim',nyl);
	get(axb(i),'ylim'); set(axb(i),'ylim',ans+diff(ans).*[1 -1]*par.zoomfactor); % zoom in by same factor 
      else		% and change other plots like this:
	set(axb(i),'ylim',nyl);
	get(axb(i),'xlim'); set(axb(i),'xlim',ans+diff(ans).*[1 -1]*par.zoomfactor); % zoom in by same factor 
      end
    end
  end
  set(amap,'visible','off');
 case 'uparrow'
  if ~isempty(get(h,'Markerindices'))
    set(gca,'xlim',mima(x(mi))+[-1 1]*par.zoomfactor*max(diff(mima(x(mi))),.001), 'ylim',mima(y(mi))+[-1 1]*par.zoomfactor*max(diff(mima(y(mi))),.001)); 
    for i=1:nalx-1 
      if ~all(isnan(xb{i})) & ~all(isnan(yb{i}))
	if atyp==1	% When zooming in pressure plot, change other plots like this:
	  set(axb(i),'xlim',mima(xb{i}(mi))+[-1 1]*par.zoomfactor*max(diff(mima(xb{i}(mi))),.001),'ylim',mima(x(mi))+[-1 1]*par.zoomfactor*max(diff(mima(x(mi))),.001)); 
	else		% When zooming in other plots
	  if btyp(i)==1	% change pressure plot like this:
	    set(axb(i),'ylim',mima(yb{i}(mi))+[-1 1]*par.zoomfactor*max(diff(mima(yb{i}(mi))),.001),'xlim',mima(y(mi))+[-1 1]*par.zoomfactor*max(diff(mima(y(mi))),.001)); 
	  else		% and change other plots like this:
	    set(axb(i),'xlim',mima(xb{i}(mi))+[-1 1]*par.zoomfactor*max(diff(mima(xb{i}(mi))),.001),'ylim',mima(y(mi))+[-1 1]*par.zoomfactor*max(diff(mima(y(mi))),.001)); 
	  end
	end
      end
    end
    set(amap,'visible','off');
  end 
 case 'downarrow'
  get(gca,'userdata'); set(gca,'xlim',ans(1:2),'ylim',ans(3:4)); 
  for i=1:nalx-1
    get(axb(i),'userdata'); set(axb(i),'xlim',ans(1:2),'ylim',ans(3:4)); 
  end
  set(amap,'visible','on');
 case {'c','x','b','v','t','g'}					% ZOOM AND PAN:
  if ismember(atyp,[2 3 4])					% Only allowed in main plots
    nxl=get(gca,'xlim'); nyl=get(gca,'ylim');			% Get current ranges
    ii=find(nyl(1)<y&y<nyl(2));					% Data in current depth range 
    switch key, 
     case 'c', nxl=nxl+diff(nxl).*[1 -1]*par.zoomfactor-mean(nxl)+nanmean(x(ii)); % xoom in x
     case 'x', nxl=nxl+diff(nxl).*[-1 1]*par.zoomfactor-mean(nxl)+nanmean(x(ii)); % zoom out x
     case 'b', nyl=nyl+diff(nyl).*[1 -1]*par.zoomfactor-mean(nyl)+nanmean(y(ii)); % xoom in y
     case 'v', nyl=nyl+diff(nyl).*[-1 1]*par.zoomfactor-mean(nyl)+nanmean(y(ii)); % zoom out y
     case 't'; nyl=nyl-diff(nyl).*par.zoomfactor;				% move up y
     case 'g'; nyl=nyl+diff(nyl).*par.zoomfactor;				% move down y
    end
    ii=find(nxl(1)<x&x<nxl(2) & nyl(1)<y&y<nyl(2));		% Check for data in new range 
    xok=abs(diff(mima(x(ii)))/diff(nxl))>par.zoomfactor/50;	% Not too small x-extent of data
    yok=abs(diff(mima(y(ii)))/diff(nyl))>par.zoomfactor/50; 	% Not too small y-extent of data
    if length(ii)>2 & xok & yok					% And require three points
      switch key
       case {'c','x'},		set(gca,'xlim',nxl);		% The change is in x-direction
       case {'b','v','t','g'},	set(gca,'ylim',nyl);		% The change is in y-direction
      end
      for i=1:nalx-1							% The other plots:
	if btyp(i)==1,	set(axb(i),'xlim',nyl,'ylim',ii([1 end]));	% change pressure plot like this
	else		set(axb(i),'ylim',nyl);				% change other plots like this
	end
      end
      set(amap,'visible','off');				% Always turn off map when changing frame
    end
  end
 case 'z', fl(mi)='0';	
 case '1', fl(mi)='1';	
 case '2', fl(mi)='2';	
 case '3', fl(mi)='3';	
 case '4', fl(mi)='4';	
 case '5', fl(mi)='5';	
 case '6', fl(mi)='6';	
 case '7', fl(mi)='7';	
 case '8', fl(mi)='8';	
 case '9', fl(mi)='9';	
 case 'q', tx=~tx;
 case 'p', 
  if ~isempty(amap)
    switch get(amap(1),'visible')
     case 'on', set(amap,'visible','off');
     case 'off', set(amap,'visible','on');
    end
  end
 case 'escape'
  fl=par.oldflags(:,atyp); 
  set(h,'Userdata',fl);
  for i=1:nalx-1, set(hb(i),'Userdata',par.oldflags(:,btyp(i))); end
  newflags=true;
 case 'space'
  get(gcf,'name'); 
  if ~contains(ans,'checked')	% First time just mark (will open the next)
    set(gcf,'name',[ans,' checked']); 
  else				% If revisited, jump to last profile.
    openfigs=findobj('-regexp','name','check_profiles:');
    Nfig=max(cell2mat(get(openfigs,'number')));
    figure(Nfig);
  end
 case 'return'
  % Check that all figures have 'checked' in name. If not go to the
  % final one and ask if it is approved, and press enter again:
  openfigs=findobj('-regexp','name','check_profiles:');
  if length(openfigs)>1
    Nfig=max(cell2mat(get(openfigs,'number')));
  else
    Nfig=get(openfigs,'number');
  end
  if get(gcf,'number')~=Nfig & ~all(contains(get(openfigs,'name'),'checked'))
    % When not looking at the last one and not all checked:
    figure(Nfig);
    msgbox('Have you approved this figure? If so, press <enter> again.',...
	   'What about the last figure?');
  else
    % All but the current has name 'checked', then open the final dialog:
    answer=questdlg(['You can edit the flags in all open figures', ...
		     ' before ending this session.', ...
		     ' Do not close any figure windows before ending session!',...
		     ' Output flag matrices will be based on information from', ...
		     ' all figures, when ending the session.',...
		     ' All unflagged data in processed profiles will be flagged as good ''1''.',...
		     ' Do you want to end session now?'],...
		    'End session now?','Yes','No','No');
    if strcmp(answer,'Yes')
      get(Nfig,'name'); set(Nfig,'name',[ans,' last checked']); % To stop profile loop in CHECK_PROFILES
      set(0,'Tag','end check');					% To stop CHECK_PROFILES completely at any point
    end
  end
 case 'm', msgbox(helptext,'keystroke Menu');
 case 'n', msgbox(instructions,'iNstructions');
 case 'f', msgbox(join(argoflags,' - ',2),'Flag meanings');
 otherwise
  return 
end

% Safety checks:
if it<n1, it=n1; end	% Cannot be < first non nan				
if ib<n1, ib=n1; end	% Cannot be < first non nan		
if ib>n2, ib=n2; end	% Cannot be > last non nan
if it>n2, it=n2; end	% Cannot be > last non nan
if it>double(mi(end)), ib=it; end	% push ib down with it
if ib<double(mi(1)),   it=ib; end	% push it up with ib


if nalx==4 & contains('cx',key)	& ismember(atyp,[2 3])	% x-zoom change
  % When there is a pure x-zoom, update the 4th plot according to the
  % limits of the other two:
  get(get(alx(4),'xlabel'),'String'); % Type of auxillary plot (the 4th panel)
  switch ans
   case 'Potential density'
    sw_pden(get(alx(3),'xlim'),fliplr(get(alx(2),'xlim')),get(alx(1),'xlim'),0);	
    if isreal(ans), set(alx(4),'xlim',sort(ans)); end	
  end
end

if contains('yuiohjklased',key)				% Region change
  set(h,'Markerindices',[it:ib]');
end

if contains('z123456789',key) & ~isempty(get(h,'Markerindices')) % Flag change 
  set(h,'Userdata',fl);
  newflags=true;
  if atyp==1	% Update passive pressure flag markers
    set(hPi,'Markerindices',find(fl~='1' & fl~=' '));
  end
end

if newflags | strcmp(key,'q') & tx 	% If new flags or text toggled on
  fontsize=get(gca,'fontsize');
  delete(hx); 
  fl~='1' & fl~=' '; hx=text(x(ans),y(ans),fl(ans),'clipping','on'); 
  set(hx,'color','k','horizontalalignment','center','clipping','on','fontsize',fontsize,'Tag','check_profiles_text');
  tx=true;
end

if strcmp(key,'escape')			% If there is a need to update flag text in all axes
  axa=gca;							% Get current axes
  for i=1:nalx-1						% Loop other axes
    set(gcf,'currentaxes',axb(i));				% Go to i-th other axes
    delete(findobj(axb(i),'Tag','check_profiles_text'));	% Delete text object
    flb=get(hb(i),'Userdata');					% Get flags
    flb~='1' & flb~=' ';					% Ignore good or blanks 
    hxb=text(xb{i}(ans),yb{i}(ans),flb(ans),'clipping','on');	% Put new text on
    set(hxb,'color','k','horizontalalignment','center','fontsize',fontsize,'Tag','check_profiles_text');
  end
  set(gcf,'currentaxes',axa);					% Go back to current axes
end

if ~tx 
  delete(hx); 
end

