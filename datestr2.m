function s=datestr2(n,dateform)
% DATESTR2      serial day number to string date
% This function is supplementary to the original DATESTRING,  
% in that it covers additional date-formats.
%
% s=datestr2(n,dateform)
%
% n         = serial (Julian) days where 1 corresponds to 1-Jan-0000
% dateform  = format of output date-string   (default=100, see below)
%
% d         = integer or string date depending on specified format 
%
%             DATEFORM number   DATEFORM string         Example
%                100            'yymmdd'               '691121'    
%                101            'mmm dd yyyy'          'Nov 21 1969'
%                102            'mm/dd/yyyy'           '11/21/1969'
%		 103		'mm.yyyy'		'11.1969'
%		 104		'dd/mm/yy'		'21/11/69'
%		 105		'd/m'			'9/8' (not 09/08)
%		 106		'd/m-yy'		'9/8-70' 
%		 107		'dd.mm.yyyy'		'09.08.1970' 
%		 108            'mmm dd yyyy hh:mm:ss'  'Nov 21 1969 12:13:14'
%		 109	'yyyy-mm-ddTHH:MM:SS'		'1991-01-01T00:00:00'
%		 110	'yyyy-mm-ddTHH:MM:SS+hh:mm'	'1991-01-01T00:00:00+00:00'
%		 111	'yyyy-mm-ddTHH:MM:SSZ'		'1991-01-01T00:00:00Z'
%                112            'yyyymmdd'              '19691121'    
%
% See also DATENUM2 DATENUM, DATEAXIS, DATESTR, DATEVEC, NOW, DATE

switch dateform
 case 100
  yy=datestr(n,11); datestr(n,6); mm=ans(:,1:2); dd=ans(:,4:5);
  s=strcat(yy,mm,dd);
 case 101
  yyyy=datestr(n,10); mmm=datestr(n,3);  dd=datestr(n,7); %dd=ans(:,4:5);
  s=char(strcat(mmm,{' '},dd,{' '},yyyy));
 case 102
  datestr(n,6); mm=ans(:,1:2); dd=ans(:,4:5); yyyy=datestr(n,10);
  s=strcat(mm,'/',dd,'/',yyyy);
 case 103
  datestr(n,6); mm=ans(:,1:2); yyyy=datestr(n,10);
  s=strcat(mm,'.',yyyy);
 case 104
  datestr(n,6); mm=ans(:,1:2); dd=ans(:,4:5); yy=datestr(n,11);
  s=strcat(dd,'/',mm,'/',yy);
 case 105
  mm=datestr(n,5); mm=str2num(mm); mm=num2str(mm);
  dd=datestr(n,7); dd=str2num(dd); dd=num2str(dd);
  s=strcat(dd,'/',mm);
 case 106
  mm=datestr(n,5); mm=str2num(mm); mm=num2str(mm);
  dd=datestr(n,7); dd=str2num(dd); dd=num2str(dd);
  yy=datestr(n,11);
  s=strcat(dd,'/',mm,'-',yy);
 case 107 % '09.08.1970' 
  mm=datestr(n,5); %mm=str2num(mm); mm=num2str(mm,'%2.0f');
  dd=datestr(n,7); %dd=str2num(dd); dd=num2str(dd,'%2.0f');
  yyyy=datestr(n,10);
  s=strcat(dd,'.',mm,'.',yyyy);
 case 108 % 'Nov 21 1969 12:13:14'
  yyyy=datestr(n,10); mmm=datestr(n,3); dd=datestr(n,7); %dd=ans(:,4:5);
  time=datestr(n,13);
  s=char(strcat(mmm,{' '},dd,{' '},yyyy,{' '},time));
 case 109 % '1991-01-01T00:00:00'
  mm=datestr(n,29); 
  dd=datestr(n,13); 
  s=strcat(mm,'T',dd);
 case 110 % '1991-01-01T00:00:00+00:00'
  mm=datestr(n,29); 
  dd=datestr(n,13); 
  s=strcat(mm,'T',dd,'+00:00');
 case 111 % '1991-01-01T00:00:00Z'
  mm=datestr(n,29); 
  dd=datestr(n,13); 
  s=strcat(mm,'T',dd,'Z');
 case 112 % '19691121'    
  mm=datestr(n,5);
  dd=datestr(n,7);
  yyyy=datestr(n,10);
  s=strcat(yyyy,mm,dd);
 otherwise
  s=datestr(n,dateform);
end
