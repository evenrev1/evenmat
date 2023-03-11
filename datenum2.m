function n=datenum2(d,dateform)
% DATENUM2      integer or string date to serial day number.
% This function is an extension of the original DATENUM,  
% in that it covers extra date-formats in addition to the original ones.
%
% n=dato(d,dateform)
%
% d         = integer or string date depending on given format 
% dateform  = format of input date-string   (default=100, see below)
%
% n         = serial days where 1 corresponds to 1-Jan-0000
%
%             DATEFORM number   DATEFORM string         Example
%               30 (ISO 8601)   'yyyymmddTHHMMSS'       20000301T154517 
%               100             'yymmdd'                691121    
%               101             'mmm dd yyyy'           'Nov 21 1969'
%               102             'mm/dd/yyyy'            '11/21/1969'
%               103             'mm.yyyy'               '11.1969'
%               104             'dd/mm/yy'              '21/11/69'
%               105(unaplicable)'d/m'                   '9/8' (not 09/08)
%               106             'd/m-yy'                '9/8-70' 
%		107		'dd.mm.yyyy'		'09.08.1970' 
%               108             'mmm dd yyyy hh:mm:ss'  'Nov 21 1969 12:13:14'
%               109        'yyyy-mm-ddTHH:MM:SS'	'1991-01-01T00:00:00'
%               110        'yyyy-mm-ddTHH:MM:SS+hh:mm'  '1991-01-01T00:00:00+01:00'
%               111        'yyyy-mm-ddTHH:MM:SSZ'       '1998-04-19T09:04:48Z'
%               112		'yyyymmdd'              '19691121'    
% 
% In addition to be the inverse operator of DATESTR2 on the same "new"
% formats, this function is also able to convert some of the string
% formats that is not covered in DATENUM.
%
% See also DATESTR2 DATENUM, DATEAXIS, DATESTR, DATEVEC, NOW, DATE

%This is based on the old DATO-function
%Time-stamp:<Last updated on 05/08/11 at 09:49:11 by even@nersc.no>
%File:</home/even/matlab/evenmat/datenum2.m>

error(nargchk(1,2,nargin));
if nargin < 2 | isempty(dateform)
  dateform=100;
end

switch dateform
 case 30
  yyyy=d(:,1:4); mm=d(:,5:6); dd=d(:,7:8);
  HH=d(:,10:11); MM=d(:,12:13); SS=d(:,14:15);
  mn=datenum(strcat(mm,'/',dd,'/',yyyy)); % for finding the month (mmm)
  mmm=datestr(mn,3);
  s=strcat(dd,'-',mmm,'-',yyyy,{' '},HH,':',MM,':',SS); % 'dd-mmm-yyyy HH:MM:SS'
  n=datenum(s);
 case 100
  yy=d(:,1:2); mm=d(:,3:4); dd=d(:,5:6);
  s=strcat(mm,'/',dd,'/',yy);
  n=datenum(s);
 case 101
  da=char(d); 
  yyyy=da(:,8:11); mmm=da(:,1:3); dd=da(:,5:6);
  % The string S must be in one of the date formats
  % 0,1,2,6,13,14,15,16 (as defined by DATESTR).
  n=datenum(strcat(dd,'-',mmm,'-',yyyy));
 case {102,107} % '09/08/1970' % '09.08.1970' 
  yy=d(:,9:10); mm=d(:,1:2); dd=d(:,4:5);
  s=strcat(mm,'/',dd,'/',yy);
  n=datenum(s);
 case 103
  da=char(d); 
  y=str2num(da(:,4:7)); m=str2num(da(:,1:2)); d=1;% first of month
  n=datenum(y,m,d);
 case 104
  yy=d(:,7:8); mm=d(:,4:5); dd=d(:,1:2);
  s=strcat(mm,'/',dd,'/',yy);
  n=datenum(s);
 case 105
  error('Serial date number cannot be found from a yearless string!');
 case 106
  error('Interpretation of "d/m-yy" not impemented yet!');
  dm=findstr(d,'/'), my=findstr(d,'-'),
%  y=str2num(d(:,my+1:end)), m=str2num(d(:,dm+1:my-1)), d=str2num(d(:,1:dm-1)),
  yy=d(:,my+1:end), mm=d(:,dm+1:my-1), dd=d(:,1:dm-1),
  %yy=datestr(d(:,my+1:end)),11), 
  %mm=datestr(d(:,dm+1:my-1)),5),
  %dd=datestr(num2str(d(:,1:dm-1)),7),
  s=strcat(mm,'/',dd,'/',yy),
  n=datenum(s),
 %case 107 % above
 case 108 % 'Nov 21 1969 12:13:14'
  da=char(d); 
  yyyy=da(:,8:11); mmm=da(:,1:3); dd=da(:,5:6);
  HH=d(:,13:14); MM=d(:,16:17); SS=d(:,19:20);
  s=strcat(dd,'-',mmm,'-',yyyy,{' '},HH,':',MM,':',SS); % 'dd-mmm-yyyy HH:MM:SS'
  n=datenum(s);
 case {109,111} % '1991-01-01T00:00:00' % '1998-04-19T09:04:48Z'
  yyyy=str2num(d(:,1:4)); mm=str2num(d(:,6:7)); dd=str2num(d(:,9:10));
  HH=str2num(d(:,12:13)); MM=str2num(d(:,15:16)); SS=str2num(d(:,18:19));
  n=datenum(yyyy,mm,dd,HH,MM,SS);
 case 110 % '1991-01-01T00:00:00+01:00'
  yyyy=str2num(d(:,1:4)); mm=str2num(d(:,6:7)); dd=str2num(d(:,9:10));
  HH=str2num(d(:,12:13)); MM=str2num(d(:,15:16)); SS=str2num(d(:,18:19));
  pHH=str2num(d(:,21:22)); pMM=str2num(d(:,24:25));
  HH=HH+pHH; MM=MM+pMM;
  n=datenum(yyyy,mm,dd,HH,MM,SS);
 case 111 % above
 case 112 % '19691121'
  yyyy=str2num(d(:,1:4)); mm=str2num(d(:,5:6)); dd=str2num(d(:,7:8));
  n=datenum(yyyy,mm,dd);
 otherwise
  n=datenum(d,dateform);
end
