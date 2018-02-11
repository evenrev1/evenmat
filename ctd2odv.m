function ctd2odv(stations,outopt)
% CTD2ODV       A conversion routine for (Seasoft) ctd-files
%
% This function searches all available ctd-files named HM026xxx (.HDR and
% .ASC), where the xxx corresponds to station number. Input integer numbers
% of stations to search for.  Missing files are just skipped.
%
% ctd2odv(stations,outopt)
%
% stations     = vector of station numbers (those corresponding to filenames). 
%                Give as range 1:109, specific stations [1 5 14 16],  etc.
% outopt       = string of one or more of the following options for additional 
%                output (in addition to the ODV-formatted file).
%                
%                'skf'   : "one station in one row, one file for each
%                          variable" requested by Soenke Maus. Goes in
%                          one .SKF file for each variable. First
%                          variable-column is for 0m, next for 1m, etc. 
%                'abdir' : One file with the columns...
%                          Ship, cruise, station, lon, lat, temp(5m) and
%                          sal(5m) 
%                'vec'   : Corresponding matlab vectors for all
%                          parameters and variables (NOT IMPLEMENTED!)
%
% OUTPUT:        Always the file with name HM026_odv.txt 
%                (in fact, [outname,'_odv.txt'] ,see customization-section
%                below) as well as the additional outputs described above.
%
% REQUIREMENTS:  Runs on 5.3. Requires TEXTREAD.M.
%
% WARNING:       This was made on a wavy Storfjorden, so it has pretty
%                cludgy and coffee-stained coding. Edit at own risk! 
%
% Created by even@gfi.uib.no 
% on r/v Haakon Mosby in Storfjorden, Svalbard, september 2000.
% Changed a bit summer 2001
%Time-stamp:<Last updated on 02/04/19 at 14:01:17 by even@gfi.uib.no>
%File:<d:/home/matlab/ctd2odv.m>

global path basisfilename oname varform skname skvarnames maxdepth abdname bottname maxbottles
lines=0; skname=''; abdname='';            % initialization of some variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CUSTOMIZATION: %%%%%%%%%%%%%
% cruise specific parameters:
path='';                        % path for input data
basisfilename='HM026000';       % the basis for filename of ctd-storage 
                                % (000 are replaced by station numbers). 
outname='HM026';                % the name of the output file
headstring=['Cruise\tStation\tType\tMon/Day/yr\tLon [E]\tLat[E]\t',...
	    'Bot.Depth [m]\tPressure [db]\tTemperature [deg C]\t',...
	    'Oxygen [ml/l]\tSalinity [psu]\tLight-trans. [percent]\t',...
	    'Sigma_t [kg/m3]\tPot.temp [deg C]\n'];
maxdepth=400;               % max number depth-samples at a station
maxbottles=9;               % max number of bottles closed at one station
% 
% The header-file is often different from cruise to cruise.  Header file
% parameter-names and code for reading corresponding values, can be edited
% below (search for 'PARAMETERS').
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


error(nargchk(1,2,nargin));      % input-tests
if nargin<2 | isempty(outopt)
   outopt='';
end
                                % create (clear) files for SoenKes Format, SKF 
if any([findstr(outopt,'skf'),...
        findstr(outopt,'soenke'),findstr(outopt,'sonke')])
  skvarnames={'temperature' 'oxygen' 'salinity' 'lightxmiss' 'sigma_t' 'pottemp'};
  skname=strcat(repstr([path,outname,'_'],6),skvarnames',repstr('.skf',6));
  for i=1:length(skvarnames), skid=fopen(skname{i},'w');  fclose(skid); end    % clear SKF-files
  varform=repstr('%8.3f ',1,maxdepth,'char');   % long format string for the variables
end
if findstr(outopt,'abd')     % For Abdir's desires
   abdname=[path,outname,'.abd'];  % 5 meter sal and temp
   abdid=fopen(abdname,'w'); 
   fprintf(abdid,'%%Ship Cruise Day  Lon   Lat    Station  Temp_5   Sal_5 Depth\n'); 
   fclose(abdid);  
   bottname=[path,outname,'_bottles.abd'];  % Bottledepths
   bottid=fopen(bottname,'w'); 
   fprintf(bottid,['%%Ship Cruise Day  Lon   Lat    Station ',int2str(1:maxbottles),'\n']); 
   fclose(bottid);  
end
if findstr(outopt,'vec')
   disp('Vector-output not implemented yet.');
end

fprintf(1,'\n');
names=createfilename(stations);              % create sequence of filenames to search for
oname=[path,outname,'_odv.txt'];              % open (clear) ODV-file for output
oid=fopen(oname,'w'); fprintf(oid,headstring); fclose(oid); 

for i=1:length(stations)                     % loop through infiles and process them
   lines=dofile(names{i})+lines;             % record total number of datalines processed
end

if lines                                     % A final message
   fprintf(1,'\n%d lines of data exported to ODV-file %s\n',lines,oname);
   if ~isempty(skname), fprintf(1,'Data also exported to six .skf files in Soenke-format\n'); end
   if ~isempty(abdname), fprintf(1,'Data also exported to %s in Abdir-format\n',abdname); end
else
   feval('delete',oname);
   fprintf(1,'No datafile created.\n');
end
fprintf(1,'\n');

%end of master-function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% THE ROUTINE THAT DOES IT ALL: %%%%%%%%%%%
function m=dofile(name)
global path oname varform skname skvarnames maxdepth abdname bottname maxbottles
m=0; strt=1;
hname=[path,name,'.HDR'];                    
hid=fopen(hname,'r');                   % open the headerfile  %%% .HDR %%%
if hid==-1                              % skip if not found
  fprintf(1,'... Can''t open file %s\n',hname); break; 
end 
  asciihead=fread(hid,'char');                  % read the headerfile
fclose(hid);
ahd=char(asciihead');                           % convert read ascii-code to one string
rets=findstr(char(13),ahd);                     % find all end-of-lines in this string
% Search out and extract the different PARAMETERS: 
% Some parameters may have different length from station to station, 
% so we use the found end-of-lines as end-of-field
findstr('Cruise: ',ahd);                      cruise     =ahd(ans+8:ans+8+5);
findstr('Station Nr = ',ahd);
sta=ans+13;rets(find(rets>=sta));sto=ans(1)-1;station    =str2num(ahd(sta:sto));
                                              type       = 'c';
findstr('System UpLoad Time = ',ahd);                     
jday=datenum2(ahd(ans+21:ans+21+10),31);      datostreng =datestr2(jday,32);     % ODV likes 10/27/1999
findstr('Long: ',ahd);
sta=ans+5;rets(find(rets>=sta));sto=ans(1)-1; lon        =str2num(ahd(sta:sto));
findstr('Lat: ',ahd);  
sta=ans+5;rets(find(rets>sta));sto=ans(1)-1;  lat        =str2num(ahd(sta:sto));
findstr('Depth = ',ahd);                   
sta=ans+8;rets(find(rets>sta));sto=ans(1)-1;  bdepth     =str2num(ahd(sta:sto));

switch length(lon)
case 1, longitude = deg2num(lon);               % lon and lat should be decimal degrees
case 2, longitude = deg2num(lon(1),lon(2));     % and thy might be given as one or two numbers
end
switch length(lat)
case 1, latitude  = deg2num(lat);
case 2, latitude  = deg2num(lat(1),lat(2));
end

dname=[path,name,'.asc'];                       % Open and read the variables-file (.ASC)
%test
fid=fopen(dname,'r'); 
if fid==-1, fprintf(1,'... Can''t open file %s\n',dname); break; end % skip if not found
fclose(fid);
%read
[press,temp,xmiss,sal,oxy,dens,ptemp]=textread(dname,...
   '%f %f %*f %f %f %f %f %f','headerlines',1);

%fprintf(1,'Processing file %s',name);
%fprintf(1,'  -  station %4d  - %4d lines.  Sample of output (line 1):\n',station,m); % onscreen-message
fprintf(1,'%s\t%4d\t%s\t%s\t%6.3f\t%6.3f\t%d\t%d\t%f\t%f\t%f\t%f\t%f\t%f\n',...       % an ODV-sample
      cruise,station,type,datostreng,longitude,latitude,bdepth,... % pars
      press(1),temp(1),oxy(1),sal(1),xmiss(1),dens(1),ptemp(1));  


                                                              %%%%% OUTPUT: %%%%%
%--------------------------------------------------------------------------------
if ~isempty(skname)                       % SKF ascii-file output (Soenke-format)
   % build uniform length column-vectors of the variables:
   strt=round(press(1));                  % start on the right index (1st column = 1m)
   temperature=999*ones(1,maxdepth); temperature(strt+[1:length(temp)])  =temp';
   oxygen=999*ones(1,maxdepth);      oxygen(     strt+[1:length(oxy)])   =oxy';
   salinity=999*ones(1,maxdepth);    salinity(   strt+[1:length(sal)])   =sal';
   lightxmiss=999*ones(1,maxdepth);  lightxmiss( strt+[1:length(xmiss)]) =xmiss';
   sigma_t=999*ones(1,maxdepth);     sigma_t(    strt+[1:length(dens)])  =dens';
   pottemp=999*ones(1,maxdepth);     pottemp(    strt+[1:length(ptemp)]) =ptemp';
   % write to files:
   for i=1:length(skname)
      skid=fopen(skname{i},'a');
      skformat=['%s %s %4d %8.3f %7.3f %d ',varform,'\n'];
      eval(['fprintf(skid,skformat,''001'',cruise(3:6),station,longitude,latitude,datenum2(datostreng,32),',skvarnames{i},');']);
      fclose(skid);
   end
end
%--------------------------------------------------------------------------------
if ~isempty(abdname)                      % ABD ascii-file output (Abdir's wish)
                                                          % 5 meter sal and temp
   if press(1)>5,  fem_meter=press(1); mess=press(1);
   else            fem_meter=find(round(press)==5); mess=5;
   end
   abdid=fopen(abdname,'a'); 
   fprintf(abdid,'%s %s %d %8.3f %7.3f %4d %8.3f %8.3f %4d\n',...
      '001',cruise(3:6),datenum2(datostreng,32),longitude,latitude,station,...
      temp(fem_meter),sal(fem_meter),mess);
   fclose(abdid);
   % Bottledepths
   % reading
   bottledepths=ones(1,maxbottles)*(-9); 
   % a test
   btlname=[path,name,'.btl'];
   headerlines=findline('Position        Time',btlname); % insert a known string on last
                                                         % line of header
   if ~isempty(headerlines)         % findline works as a test for file-existence
      [bnr,btd]=textread(btlname,...
         '%d %*11c %*f %*f %f %*f %*f %*d %*s\n %*8c %*f %*f %*f %*d %*s\n',...
         'headerlines',headerlines);
      bottledepths(bnr)=round(btd);
      % writing
      bottformat=repstr('%4d ',1,maxbottles,'char');
      bottid=fopen(bottname,'a'); 
      fprintf(bottid,['%s %s %d %8.3f %7.3f %4d ',bottformat,'\n'],...
         '001',cruise(3:6),datenum2(datostreng,32),longitude,latitude,station,...
         bottledepths); 
      fclose(bottid);  
   end
end
%--------------------------------------------------------------------------------
oid=fopen(oname,'a');                     % ODV-file out (always)
m=length(sal);
for i=1:m
   fprintf(oid,'%s\t%4d\t%s\t%s\t%6.3f\t%6.3f\t%d\t%d\t%f\t%f\t%f\t%f\t%f\t%f\n',...
      cruise,station,type,datostreng,longitude,latitude,bdepth,...           % pars
      press(i),temp(i),oxy(i),sal(i),xmiss(i),dens(i),ptemp(i));             % vars
end
fclose(oid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function line=findline(string,file)

fid=fopen(file,'r');                            % open the headerfile  %%%%% .HDR %%%%%
if fid==-1, 
   fprintf(1,'... Can''t open file %s\n',file); % skip if not found
   line=[];
else
   contents=fread(fid,'char');                  % read the headerfile
   fclose(fid);
   ahd=char(contents');                         % convert read ascii-code to one string
   rets   = findstr(char(13),ahd);              % find all end-of-lines in this string
   strpos = findstr(string,ahd);                % find position of string 
   rets_before_string = find(rets<strpos);      % find the newlines before string
   line=length(rets_before_string)+1;           % string is on the line after number of newlines
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Builds namestrings from basisfilename and station-number-secuence
function name=createfilename(stations)
global basisfilename
n=length(stations);
name=char(repstr(basisfilename,n));
for i=1:n
   if     stations(i)<10,   name(i,end)      =num2str(stations(i));
   elseif stations(i)<100,  name(i,end-1:end)=num2str(stations(i));
   elseif stations(i)<1000, name(i,end-2:end)=num2str(stations(i));
   end      
end
name=cellstr(name);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function deg=deg2num(d,m,s)
% DEG2NUM       deg,min,sec ordinates into decimal ordinates
%
% deg=deg2num(d,m,s)
%
% d,m,s = degree,minutes,seconds for an ordinate
% deg   = decimal degree ordinate
%
% See also POS2STR

% Input tests:
error(nargchk(1,3,nargin));
N=length(d);
if nargin<3 | isempty(s), s=zeros(N,1); end
if nargin<2 | isempty(m), m=zeros(N,1); end
if ~isnumeric([d;m;s])
  error('Numeric input only!');
elseif ismatrix(d) | ismatrix(m)| ismatrix(s)
  error('Single or vector input only!');
elseif any(d<-180) | any(180<d)
  error('Bad numbers (degrees outside [-180,180])!');
elseif N~=length(m) | length(m)~=length(s)
  error('All input vectors must have same length!');
end
seconds=3600*d+60*m+s;
deg=seconds/3600;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rstr=repstr(string,M,N,opt)
% REPSTR        create cellstring array with identical cells
% Repeates a string in a cellstring, i.e. creates cellstr with same string
% in all elements. This is handy when trying to STRVCAT a multiline
% character object with a single string (add same ending to several
% strings), or when creating format-strings for same format repeated. 
% REPSTR is reminiscent of ONES and ZEROS.
% 
% rstr=repstr(string,M,N,opt)
%
% string  = a single string 
% M       = the number of rows in output cellstring
% N       = the number of columns in output cellstring
%
% opt     = special option(s):
%           'char'  :  make _character_array_ of the MxN cellstr. This just
%                      glues together the created cellstring array.
%                       
% rstr    = the MxN cellstring with 'string' in all cells (or character array)
%
%             repstr('myfile',2,3)        => 'myfile' 'myfile' 'myfile'
%                                            'myfile' 'myfile' 'myfile'
%
%             repstr('%8.3f ',1,3,'char') => %8.3f %8.3f %8.3f 
%
% An example of use is found in POS2STR.M where N,S,E,W endings is added to
% longitudes and latitudes.
%
% See also STRVCAT

error(nargchk(2,4,nargin));   % input-tests
if nargin<4 | isempty(opt)
   opt='';
end
if nargin<3 | isempty(N)
   N=1;
end

string=char(string);          % build cellstring array
rstr={''};
for j=1:N                                   % had to go in loop, because
   for i=1:M                                % cellstr cuts away spaces
      rstr{i,j}=string;                     % and repstring should repeat
   end                                      % everything
end                                     

if findstr(opt,'char')        % make character array of cellstr array
   row='';
   for j=1:N
      row=[row,char(rstr(i,j))];            % build a row of N x string
   end
   for i=1:M
      matr(i,:)=row;                        % repeat rows M times
   end
   rstr=matr;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s=datestr2(n,dateform)
% DATESTR2    serial day number to string date
% This function is supplementary to the original DATESTRING,  
% in that it covers additional date-formats.
%
% s=datestr2(n,dateform)
%
% n         = serial (Julian) days where 1 corresponds to 1-Jan-0000
% dateform  = format of output date-string   (default=30, see below)
%
% d         = integer or string date depending on specified format 
%
%             DATEFORM number   DATEFORM string         Example
%                30             'yymmdd'                691121    
%                31             'mmm dd yyyy'           'Sep 22 2000'
%                32             'mm/dd/yyyy'            '11/21/1969'
%
% See also DATENUM2 DATENUM, DATEAXIS, DATESTR, DATEVEC, NOW, DATE

switch dateform
case 30
   yy=datestr(n,11); datestr(n,6); mm=ans(1:2); dd=ans(4:5);
   s=strcat(yy,mm,dd)
case 31
   yyyy=datestr(n,10); mmm=datestr(n,3); datestr(n,6);dd=ans(4:5);
   s=[mmm,' ',dd,' ',yyyy];
case 32
   datestr(n,6); mm=ans(1:2); dd=ans(4:5); yyyy=datestr(n,10);
   s=strcat(mm,'/',dd,'/',yyyy);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function n=datenum2(d,dateform)
% DATENUM2    integer or string date to serial day number.
% This function is supplementary to the original DATENUM,  
% in that it covers additional date-formats.
%
% n=dato(d,dateform)
%
% d         = integer or string date depending on given format 
% dateform  = format of input date-string   (default=30, see below)
%
% n         = serial (Julian) days where 1 corresponds to 1-Jan-0000
%
%             DATEFORM number   DATEFORM string         Example
%                30             'yymmdd'                691121    
%                31             'mmm dd yyyy'           'Sep 22 2000'
%                32             'mm/dd/yyyy'            '11/21/1969'
%
% See also DATESTR2 DATENUM, DATEAXIS, DATESTR, DATEVEC, NOW, DATE

%This is based on the old DATO-function

error(nargchk(1,2,nargin));
if nargin < 2 | isempty(dateform)
  dateform=30;
end

switch dateform
case 30
   yy=d(1:2); mm=d(3:4); dd=d(5:6);
   s=strcat(mm,'/',dd,'/',yy);
   n=datenum(s);
case 31
   da=char(d); 
   yyyy=da(8:11); mmm=da(1:3); dd=da(5:6);
   % The string S must be in one of the date formats
   % 0,1,2,6,13,14,15,16 (as defined by DATESTR).
   n=datenum(strcat(dd,'-',mmm,'-',yyyy));
case 32
   yy=d(9:10); mm=d(1:2); dd=d(4:5);
   s=strcat(mm,'/',dd,'/',yy);
   n=datenum(s);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function answer=ismatrix(x)
% ISMATRIX      matrix object test

find(size(x)==1);
if length(ans)==0 & ~isempty(x)
  % x is a matrix
  answer=1;
else
  answer=0;
end
%eof