function [name,pos,dist,type,result] = nameinnorway(lon,lat,r,typ)
% NAMEINNORWAY	Find nearest place names of point. 
% Makes a query to https://ws.geonorge.no/stedsnavn/v1/ and extracts all
% place names within a given radius from a given geographical
% position. Can also find positions from a place name input.
% 
% [name,pos,dist,type,result] = nameinnorway(lon,lat,r,typ)
% 
% Input for point search:
% lon,lat  = position longitude, latitude.
% r        = integer search radius, in meters (default=max=2000).
% typ      = optional filter on type of environment:
%	     'marine' : marine environment.
%
% Input for name search (shifted meaning of input variable names):
% lon      = character search string
% lat      = optional filter  on type of environment (see above).
% r        = char 'true' for fuzzy search or 'false' (default) for exact. 
% 
% Output in any case:
% name     = place names
% pos      = positions of returned names, one row per name, longitudes
%            in the first column, latitudes in the second. 
% dist     = distances from position, in meters
% type     = types of the names
% result   = full, unfiltered, unsorted struct of the query result
%
% Notes: 
% Output is sorted by distance from position, only for position search.
% Coordinate system for input and output positions is 4230 (EUREF 89;
% see https://register.geonorge.no/epsg-koder). 
% May require wget or curl to be installed on system.
% There is currently an upper limit of 20 hits.
% Note that the list of marine feature types may be incomplete;
% you can examine unfiltered hits for types.
% Recommended test and validation resource: https://www.norgeskart.no
%
% Examples: 
%
% lo=5.3039; la=60.4000; % Your favourite place in Norway
% [name,pos]=nameinnorway(lo,la)
% m_proj('albers','lon',[-.04 .04]+lo,'lat',[-.02 .02]+la);
% m_grid; m_gshhs_f;
% m_text(pos(:,1),pos(:,2),name);
% m_line(pos(:,1),pos(:,2),'linestyle','none','marker','.');
%
% Alternatively, you can do a search on a name as input:
% [name,pos,dist,type,result]=nameinnorway('Nordnes')
% and then find names nearby
% [name,pos]=nameinnorway(pos(1,1),pos(1,2))
% and plot on a map as above, if you like.
%
% See also M_MAP WEBREAD

% —————————————————
% Jan Even Øie Nilsen
% https://github.com/evenrev1

if ~ischar(lon)
  error(nargchk(1,4,nargin));
  if nargin<4 | isempty(typ), typ=''; end
  if nargin<3 | isempty(r) | r>2000, r=2000; end
  sok='punkt';
elseif ischar(lon)
  error(nargchk(1,3,nargin));
  if nargin<3 | isempty(r) | islogical(r), r='false'; end
  if nargin<2 | isempty(lat), lat='';  end
  typ=lat;
  sok='navn'; 
else
  error('Input mismatch!');
end

[name,type]=deal(''); [dist,pos]=deal([]); % Init output

% Filter criteria for marine environment:
if any(contains(typ,{'sjo','sjø','marine'}))
  typ={'Sjø','sjø','Fyrlykt','kai','Kai','lykt'}; 
end

%%%%%%%%%%%%%%%% Position input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strmatch(sok,'punkt')

  % Query NMA place name API in three different ways. The
  % last is the one that works on most systems so far.
  
  try
    result=webread('https://ws.geonorge.no/stedsnavn/v1/punkt','side','1',...
		   'ost',num2str(lon),'nord',num2str(lat),...
		   'treffPerSide','20','radius',int2str(r),'koordsys','4230','utkoordsys','4230');
    disp('Using webread.');
  catch
    try
      [status,result]=system(['curl -X ''GET'' ''https://ws.geonorge.no/stedsnavn/v1/punkt?side=1',...
		    '&ost=',num2str(lon),...
		    '&nord=',num2str(lat),...
		    '&treffPerSide=20',...
		    '&radius=',int2str(r),...
		    '&koordsys=4230&utkoordsys=4230'' -H ''accept: application/json''']);
      result=jsondecode(result);			% Decode the query result 
      disp('Using curl.');
    catch
      try
	[status,result]=system(['wget --no-check-certificate --output-document=query_results.json ',... 
		    '''https://ws.geonorge.no/stedsnavn/v1/punkt?side=1',...
		    '&ost=',num2str(lon),...
		    '&nord=',num2str(lat),...
		    '&treffPerSide=20',...
		    '&radius=',int2str(r),...
		    '&koordsys=4230&utkoordsys=4230''']);
	fid=fopen('query_results.json');	% A file has been written locally
	try				 % Extra try in case the query worked in principle, but empty result
	  result=fgets(fid);
	  result=jsondecode(result); fclose(fid); delete('query_results.json');
	catch
	  result='';
	end
	disp('Using wget.');
      catch
	error('None of the query methods (webread,curl,wget) worked!');
      end
    end
  end
  
  try
    N=length(result.navn);
  catch
    N=0; disp('No name found!');
  end
    
  if N>0
    for i=1:N					% Extract info
      name{i,1}=result.navn(i).stedsnavn.skrivem_te;
      dist(i,1)=result.navn(i).meterFraPunkt;
      type{i,1}=result.navn(i).navneobjekttype;
      pos(i,1)=result.navn(i).representasjonspunkt.x_st;
      pos(i,2)=result.navn(i).representasjonspunkt.nord;
    end
    
    [dist,AI]=sort(dist); name=name(AI); type=type(AI); pos=pos(AI,:); % Sort by distance

    if ~isempty(typ)
      contains(type,typ); dist=dist(ans); name=name(ans); type=type(ans); pos=pos(ans,:);% Filter by type
    end
  end

%%%%%%% NAME STRING SEARCH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif strmatch(sok,'navn')
  try
    % result=webread('https://ws.geonorge.no/stedsnavn/v1/navn?sok=Nordnes&fuzzy=true'); 
    result=webread(['https://ws.geonorge.no/stedsnavn/v1/navn?',...
		    'sok=',lon,...
		    '&fuzzy=',r,...
		    '&&utkoordsys=4230']); 
    disp('Using webread.');
  catch
    try 
      % [status,result]=system('curl -X ''GET'' ''https://ws.geonorge.no/stedsnavn/v1/navn?sok=Nordnes&fuzzy=true'' -H ''accept: application/json''');
      [status,result]=system(['curl -X ''GET'' ''https://ws.geonorge.no/stedsnavn/v1/navn?',...
		    'sok=',lon,...
		    '&fuzzy=',r,...
		    '&utkoordsys=4230'' -H ''accept: application/json''']);
      result=jsondecode(result);		
      disp('Using curl.');
    catch
      try
	% [status,result]=system('wget --no-check-certificate --output-document=query_results.json ''https://ws.geonorge.no/stedsnavn/v1/navn?sok=Nordnes&fuzzy=true''');
	[status,result]=system(['wget --no-check-certificate --output-document=query_results.json ',... 
		    '''https://ws.geonorge.no/stedsnavn/v1/navn?',...
		    'sok=',lon,...
		    '&fuzzy=',r,...
		    '&utkoordsys=4230''']);
	fid=fopen('query_results.json'); 	% A file has been written locally
	try	 % Extra try in case the query worked in principle, but empty result
	  result=fgets(fid);
	  result=jsondecode(result); fclose(fid); delete('query_results.json');
	catch
	  result='';
	end
	disp('Using wget.');
      catch
	error('None of the query methods (webread,curl,wget) worked!');
      end
    end
  end
    
  N=length(result.navn);

    
  for i=1:N					% Extract info
    name{i,1}=result.navn(i).skrivem_te;
    type{i,1}=result.navn(i).navneobjekttype;
    pos(i,1)=result.navn(i).representasjonspunkt.x_st;
    pos(i,2)=result.navn(i).representasjonspunkt.nord;
  end
  
  if ~isempty(typ)
    contains(type,typ); name=name(ans); type=type(ans); pos=pos(ans,:); % Filter by type
  end
  
end
