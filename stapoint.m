function [hp,hs,coord] = stapoint(varargin)
% STAPOINT	Plot some specific stations on an m_map.
%
% [hp,hs,coord] = stapoint(name1,name2, ...)
% 
% name1,...	= strings of station names, full names or just first few
%	  letters. Names will be printed at the end of station
%	  lines. If shortname (e.g. 'SV', 'EC') is input, this will
%	  be printed on map instead of full name.  
%
% hp	= handles to the line objects pinpointing stations.
% hs	= handles to the station name strings.
% coord = Cell array of position vectors [lon lat].
%         So if you wish you can obtain the coordinates for given
%         stations through this function, without them being plotted. 
%
% To see a list of available stations, type STAPOINT GET.
% 
% To change appearances (even the names), just use SET on the handles hp
% or hs afterwards. The points are not all official hydrographic
% stations, they are also points I've had the need to plot.  To add new
% stations, EDIT STAPOINT.
%
% See also SECLINE M_NAMES M_MAP

%Time-stamp:<Last updated on 06/08/29 at 09:36:15 by even@nersc.no>
%File:</home/even/matlab/evenmat/stapoint.m>

global name map_station

map_station=getstations;
hp=[]; hs=[];

if strcmp(varargin{1},'get')
  disp(strcat(char(map_station.shortname),' : ', ...
	      char(map_station.name)));
  return
end

for j=1:length(varargin)
  name=varargin{j};
  i=strmatch(lower(name),lower({map_station.name}));		% check full names
%  i=find(strcmp(lower(name),lower({map_station.name})));		% check full names
  if isempty(i),				% check shortnames
    i=strmatch(upper(name),{map_station.shortname});
    if isempty(i),				% input was not found at all
      disp(['No station name beginning with ''',name,''' is found in base!']);
      continue
    else					% input was found among shortnames
      i=justone(i);
      sta=map_station(i).shortname;
    end
  else						% input was found among full names
    i=justone(i);
    sta=map_station(i).name;
  end
    
  coord{j}=map_station(i).pos;
  
  if nargout<3,		% Plot if coord output is not requested
    hp(end+1)=m_line(coord{j}(1),coord{j}(2));		% LINE
    hs(end+1)=m_text(coord{j}(1),coord{j}(2),strcat({'  '},sta));	% TEXT
    disp(['Plotted station ''',sta,'''']);		% MESSAGE
  end

end

set(hp,'linewidth',2,'linestyle','none','color','k','marker','s','markersize',6);
set(hs,'VerticalAlignment','middle','HorizontalAlignment','left');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i=justone(i)
global name map_station
if length(i)>1
%  disp([{map_station(i).name},' all begins with ''',name,'''is found in base! Using first.']);
  strcat(strvcat(map_station(i).name),', ')';
  disp([ans(:)',' all begins with ''',name,'''!']);
  i=i(1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function map_station = getstations;
% NAMES:
map_station(1)=struct( 'pos',[    8.8833   58.3333],'name', 'Torungen'		,'shortname', 'TO');
map_station(2)=struct( 'pos',[    6.5333   58.0167],'name', 'Lista'		,'shortname', 'LI');
map_station(3)=struct( 'pos',[    4.8000   59.3167],'name', 'Utsira'		,'shortname', 'UT');
map_station(4)=struct( 'pos',[    4.9833   59.3167],'name', 'Utsira (indre)'	,'shortname', 'UT_I');
map_station(5)=struct( 'pos',[    4.8333   61.0667],'name', 'Sognesj.'		,'shortname', 'SO');
map_station(6)=struct( 'pos',[    6.7833   62.9333],'name', 'Bud'		,'shortname', 'BU');
map_station(7)=struct( 'pos',[   14.5333   68.1167],'name', 'Skrova'		,'shortname', 'SK');
map_station(8)=struct( 'pos',[   13.6333   68.3667],'name', 'Eggum'		,'shortname', 'EG');
map_station(9)=struct( 'pos',[   24.0167   71.1333],'name', 'Ingoy'		,'shortname', 'IN');
map_station(10)=struct('pos',[   17.9500   69.6500],'name', 'Hillesoy'		,'shortname', 'HI');
map_station(11)=struct('pos',[   -3.4654   54.3347],'name', 'Sellafield'	,'shortname', 'SE');
map_station(12)=struct('pos',[   -1.9060   49.6820],'name', 'La Hague'		,'shortname', 'LH');
map_station(13)=struct('pos',[   -4.6819   58.7725],'name', 'Scotland North'	,'shortname', 'SN');
map_station(14)=struct('pos',[    5.2      62.3667],'name', 'Svinoy'		,'shortname', 'SV');
map_station(15)=struct('pos',[    2        66     ],'name', 'Mike'		,'shortname', 'OWSM');
 
