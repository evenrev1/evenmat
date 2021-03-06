function dateaxis(dateform,ax,h,t0)
% DATEAXIS      changes serial day ticklabels to datestrings. 
% 
% dateaxis(dateform,ax,h,t0)
%
% dateform    = number giving the format according to the table in DATESTR
% ax          = optional string giving which axis is the time-axis 
%               ('X' (default),'Y' or 'Z')
% h	      = handle to axes to operate on
% t0          = the date of the first day of year in serial days (in case the
%               axis is not in serial days, but in days starting from 1)
%
% See also MONTHAXIS, DATENUM, DATESTR, DATEVEC, NOW, DATE

error(nargchk(0,4,nargin));
if nargin < 4 | isempty(t0),		t0=0;		end
if nargin < 3 | isempty(h),		h=gca;		end
if nargin < 2 | isempty(ax),		ax='x';		end
if nargin < 1 | isempty(dateform),	dateform=1;	end

for i=1:length(h)
  eval(['t=get(h(i),''',ax,'tick'')+t0;'])	% find the days with
                                                % labels on  originally 
  tstr=datestr(t,dateform);			% make the ticklabels
  eval(['set(h(i),''',ax,'ticklabel'',tstr);'])	% put on the ticklabels
end

addtag('dateaxis',h);				% tag the axis
%addprop(h,'axis',ax,'dateform',dateform);	% add the parameters to userdata
partoadd.axis=ax;
partoadd.dateform=dateform;
set(h,'Userdata',partoadd);
