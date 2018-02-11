function [hl,hs,coord] = secline(varargin)
% SECLINE	Plot a known hydrographic section on an m_map.
%
% [hl,hs,coord] = secline(name1,name2, ... , nameend)
% 
% name1,... = strings of section names, full names or just first
%             few letters. Mames will be printed at the end of section
%	      lines. If shortname (e.g. 'SV', 'EC') is input, this will
%	      be printed on map instead of full name.  
% nameend   = Optional number indicating at which end of the line the
%             name is to be placed: 
%             1 : At 1st (most northwestern) position in line data,
%             2 : At last position in line data (default).
%
% hl	    = handle to the line object describing section.
% hs	    = handle to the section name strings.
% coord     = Cell array of position vectors [lon1 lon2; lat1 lat2].
%             So if you wish you can obtain the coordinates for given 
%             sections through this function, without them being
%             plotted.   
%
% To see a list of available sections, type SECLINE GET.
% 
% To change appearances (even the names), just use SET on the handles hl
% or hs afterwards. The sections are not all official hydrographic
% sections, there are also some model sections I've had the need to
% plot. To add new sections, EDIT SECLINE.
%
% See also SECARROW STAPOINT M_NAMES M_MAP

%Time-stamp:<Last updated on 11/09/29 at 10:15:54 by even@nersc.no>
%File:</Users/even/matlab/evenmat/secline.m>

global name map_section

map_section=getsections;
hl=[]; hs=[];

% Check for section list inquiry
if strcmp(varargin{1},'get')
  disp(strcat(char(map_section.shortname),' : ', ...
	      char(map_section.name)));
  return
end

% Check for nameend input and set option
nameend='left'; M=length(varargin); ii=1:M;
for i=1:M, 
  if isnumeric(varargin{i}), 
    nameend='right'; ii=setdiff(1:M,i); 
  end
end
varargin=varargin(ii);

for j=1:length(varargin)
  name=varargin{j};
  %%i=find(strmatch(lower(name),lower({map_section.name})));
  %i=strmatch(lower(name),lower(strvcat(map_section.name)));	% check full names (partial)
  %if isempty(i),						% check shortnames (full) 
  if ~strcmp(lower(name),lower(strvcat(map_section.name))),	% check shortnames (full) 
    i=find(strcmp(upper(name),{map_section.shortname}));
    if isempty(i),						% input was not found at all
      disp(['No section name beginning with ''',name,''' is found in base!']);
      continue
    else					% input was found among shortnames
      %i=strmatch(lower(name),lower(strvcat(map_section.name)));
      %disp shortname
      i=justone(i);
      sec=map_section(i).shortname;
    end
  else						% input was found among full names
    keyboard
    i=strmatch(lower(name),lower(strvcat(map_section.name)));
    %disp fullname
    i=justone(i);
    sec=map_section(i).name;
  end
    
  coord{j}=map_section(i).pos;
  
  if nargout<3,					% Plot if coord output is not requested
    hl(end+1)=m_line(coord{j}(1,:),coord{j}(2,:));	% LINE
    if strmatch('right',nameend)
      hs(end+1)=m_text(coord{j}(1,1),coord{j}(2,1),sec);% TEXT AT LEFT END
    else 
      hs(end+1)=m_text(coord{j}(1,end),coord{j}(2,end),sec);% TEXT AT RIGHT
    end
    disp(['Plotted section ''',sec,'''']);		% MESSAGE
  end
  
end

set(hl,'linewidth',2,'color','k');
set(hs,'VerticalAlignment','middle','HorizontalAlignment',nameend);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i=justone(i)
global name map_section
if length(i)>1
%  disp([{map_section(i).name},' all begins with ''',name,'''is found in base! Using first.']);
  strcat(strvcat(map_section(i).name),', ')';
  disp([ans(:)',' all begins with ''',name,'''!']);
  i=i(1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function map_section = getsections;
% NAMES:
map_section(1)=struct('pos',[	20	  20	 ;
				74	  70	 ],'name', 'Fugloya-Bjornoya',	'shortname',	'FU');
map_section(2)=struct('pos',[	-6.0000	  14.0000;
				73.0000	  68.4000],'name', 'Gimsoy',		'shortname',	'GI');
map_section(3)=struct('pos',[	-4.0000	   6.5000;
				65.7500	  65.7500],'name', 'Pinro 6S',		'shortname',	'6S');
map_section(3)=struct('pos',[	-4.0000	  65.7500;
				-3.0000	  65.7500;
				-2.0000	  65.7500;
				-1.0000	  65.7500;
				-0.0000	  65.7500;
				 1.0000	  65.7500;
				 2.0000	  65.7500;
				 3.0000	  65.7500;
				 4.0000	  65.7500;
				 5.0000	  65.7500;
				 6.5000	  65.7500]','name', 'Pinro 6S',		'shortname',	'6S');
map_section(4)=struct('pos',[	      0	   5.2000;
				64.6667	  62.3667],'name', 'Svinoy',		'shortname',	'SV');
map_section(5)=struct('pos',[	-3.7530	   4.6189;
				63.3591	  60.3466],'name', 'Sognefjord',	'shortname',	'SO');
map_section(6)=struct('pos',[	 1.5000	   5.0000;
				60.0000	  60.0000],'name', 'West Coast',	'shortname',	'WC');
map_section(7)=struct('pos',[	-3.6900	  -6.4300;
				60.1800	  61.2700],'name', 'Faroe-Shetland',	'shortname',	'FSC');
map_section(8)=struct('pos',[	-5.3332	  -4.6819;
				60.3123	  58.7725],'name', 'North Scotland',	'shortname',	'NS');
map_section(9)=struct('pos',[	-5.8114	  -5.0412;
				54.6417	  54.8468],'name', 'North Channel',	'shortname',	'NC');
map_section(10)=struct('pos',[	 1.0395	   1.7918;
				51.1470	  50.7555],'name','English Channel',	'shortname',	'EC');
map_section(11)=struct('pos',fliplr(flipud([66.3480  -22.9090;
				66.7920	 -23.9580;
				67.2280	 -25.0380;	
				67.6570	 -26.1510;
				68.0770	 -27.2970]))','name','Model DS',		'shortname',	'mDS');
map_section(12)=struct('pos',fliplr(flipud([62.7790   -6.6730;
				63.2920	  -7.3950;
				63.3820	  -8.3340;
				63.8900	  -9.0900;
				63.9730	 -10.0530;
				64.4770	 -10.8460;
				64.5520	 -11.8330;
				65.0490	 -12.6650]))','name', 'Model IFR',	'shortname',	'mIFR');
map_section(13)=struct('pos',fliplr(flipud([59.0080   -4.6760;
				59.5270	  -5.3470;
				59.9570	  -5.1710;
				60.4750	  -5.8520;
				60.9020	  -5.6670;
				61.4190	  -6.3600;
				61.8430	  -6.1670]))','name', 'Model FSC',	'shortname',	'mFSC'); 
map_section(14)=struct('pos',[	 6.8507	  14.0000;
				70.55	  68.4000],'name', '"Gimsoy"',		'shortname',	'GS');
map_section(15)=struct('pos',[	33.5      33.5   ;
				72.5	  70.5   ],'name','Kola Section',	'shortname',	'KO');
map_section(16)=struct('pos',[ -32.9     -24.5   ;
				67.1	  65.5   ],'name','Denmark Strait',	'shortname',	'DS');
map_section(19)=struct('pos',[ -13.6     -7.4   ;
				65.0	  62.2   ],'name','Iceland Faroe Ridge','shortname',	'IFR');
map_section(20)=struct('pos',fliplr(flipud([60.750   4.617    ;
		   	        60.750   4.450	 ;
		   	        60.750   4.283	 ;
		   	        60.750   4.117	 ;
		   	        60.750   3.950	 ;
		   	        60.750   3.783	 ;
    			        60.750   3.617	 ;
    			        60.750   3.450	 ;
    			        60.750   3.283	 ;
    			        60.750   3.117	 ;
    			        60.750   2.933	 ;
    			        60.750   2.767	 ;
    			        60.750   2.600	 ;
    			        60.750   2.267	 ;
    			        60.750   1.917	 ;
    			        60.750   1.433	 ;
    			        60.750   0.917	 ;
    			        60.750   0.583	 ;
    			        60.750   0.250	 ;
    			        60.750   0.083	 ;
    			        60.750  -0.267	 ;
    			        60.750  -0.467	 ;
    			        60.750  -0.667]))','name','Fedje Shetland','shortname',	'FESH');
map_section(21)=struct('pos',[	-6	-6;
				62.4	66	],'name','Faroe North',	'shortname',	'FN');




return
% POSITIONS:
map_section(1).pos=[	20	  20	    ;
			74	  70	    ];
		    
map_section(2).pos=[	-6.0000	  14.0000;
			73.0000	  68.4000];
				    
map_section(3).pos=[	-4.0000	   6.5000;
			65.7500	  65.7500];
		    
map_section(4).pos=[	      0	   5.2000;
			64.6667	  62.3667];
		    
map_section(5).pos=[	-3.7530	   4.6189;
			63.3591	  60.3466];
		    
map_section(6).pos=[	1.5000	  5.0000;
			60.0000	  60.0000];
		    
map_section(7).pos=[	-3.6900	  -6.4300;
			60.1800	  61.2700];
		    
map_section(8).pos=[	-5.3332	  -4.6819;
			60.3123	  58.7725];
		    
map_section(9).pos=[	-3.6900	  -6.4300;
			60.1800	  61.2700];
		    
map_section(10).pos=[	-5.8114	  -5.0412;
			54.6417	  54.8468];
		    
map_section(11).pos=[	1.0395	  1.7918;
			51.1470	  50.7555];
		    
map_section(12).pos=flipud([	66.3480	 -22.9090;
				66.7920	 -23.9580;
				67.2280	 -25.0380;	
				67.6570	 -26.1510;
				68.0770	 -27.2970]');
		    
map_section(13).pos=flipud([	62.7790	  -6.6730;
				63.2920	  -7.3950;
				63.3820	  -8.3340;
				63.8900	  -9.0900;
				63.9730	 -10.0530;
				64.4770	 -10.8460;
				64.5520	 -11.8330;
				65.0490	 -12.6650]');
		    
map_section(14).pos=flipud([	59.0080	  -4.6760;
				59.5270	  -5.3470;
				59.9570	  -5.1710;
				60.4750	  -5.8520;
				60.9020	  -5.6670;
				61.4190	  -6.3600;
				61.8430	  -6.1670]');
