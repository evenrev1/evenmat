function [x,y,z] = tbasesec(xl,yl,N,METHOD)
% TBASESEC	Extract section of seafloor or land elevation
% Uses 5-minute TerrainBase database to trace the elevation along a
% transect. To be used togehter with M_MAP.
%
% [x,y,z] = tbasesec(xl,yl,N,METHOD)
% 
% xl,yl = Vectors (2 elements) of endpoint positions for a section, 
%         in M_MAP's x,y coordinates 
%	  (use M_LL2XY to convert from lon/lat)
% N     = single value, number of points along the section to extract
%         elevation from (default = 150).
% METHOD= method of interpolation (See INTERP2; default='spline')
%
% x,y   = Vectors of 100 points between the endpoints
%         (use M_XY2LL to convert to lon/lat)
% z     = elevation data for the points in x,y (seafloor is negative)
%
% Needs an M_MAP (M_PROJ) to be defined first! 
% M_TBASE and ETOPO5 data must be installed!
% 
% I can recommend EROCK to plot the bottom in your section.
%
% Why not lon,lat? Yes, why not? But after some consideration based on
% my own use, I chose x,y to be the input and output variable for this
% function. I found it unlikely that longitude or latitude would be the
% most used abscissa for my hydrographic sections. Km axes are hard to
% make general for an area of some size (at least I haven't had use of
% it yet), so I am often using the underlying x,y axis of M_MAP and it
% is easy to convert to lon,lat anyway.
%
% See also EROCK M_TBASEM_ll2XY KM_AXES TBASELEV 

%xl(1)=fs(1);
%xl(2)=fs(2);
%y=mean(fs(3:4));
%yl(2)=mean(fs(3:4));

%global MAP_PROJECTION MAP_VAR_LIST

error(nargchk(2,4,nargin));
if nargin<4|isempty(METHOD),		METHOD='spline';	end 
if nargin<3|isempty(N),			N=150;			end
% Test input type, single, same, two, or long
dx=diff(xl); dy=diff(yl); 
if (isempty(dx)|dx==0|length(xl)==1)	% x single/same
  if (isempty(dy)|dy==0|length(yl)==1),	y=repmat(yl(1),1,N);		% y single/same
  elseif length(yl)==2,			y=linspace(yl(1),yl(2),N);	% y two
  else					N=length(yl); y=yl;	end	% y long
  x=repmat(xl(1),1,N);
elseif length(xl)==2			% x two
  if (isempty(dy)|dy==0|length(yl)==1),	y=repmat(yl(1),1,N);		% y single/same
  elseif length(yl)==2,			y=linspace(yl(1),yl(2),N);	% y two
  else					N=length(yl); y=yl;	end	% y long
  x=linspace(xl(1),xl(2),N);
else					% x long
  N=length(xl); x=xl;
  if (isempty(dy)|dy==0|length(yl)==1),	y=repmat(yl(1),1,N);		% y single/same
  elseif length(yl)==2,			y=linspace(yl(1),yl(2),N);	% y two
  else					y=yl;			end	% y long
end

%dy=diff(yl)/N;

%x=xl(1):dx:xl(2); 
%y=yl(1):dy:yl(2); 

% dl    = For every x,y point mean elev is going to extracted from
%         an area of +- dl (in degrees) around the point. Thus the
%         'smoothness' of the output z can be adjusted by changing dl
%         (dl=0.5 gives a 9 to 12 point basis for the mean, 3x3 or
%         4x4 points). (default=0.1)
% if nargin<4|isempty(dl),		dl=.3;			 end 
% for i=1:N
%   [lo(i),la(i)]=m_xy2ll(x(i),y(i));
%   elev=m_tbase([lo(i)+dl*[-1 1] la(i)+dl*[-1 1]]);
%   z(i)=mean(elev(:));
% end
[lo,la]=m_xy2ll(x,y);
%[elev,elo,ela]=m_tbase([mima(lo)+uplus([-1 1]) mima(la)+uplus([-1 1])]);
[elev,elo,ela]=m_etopo2([mima(lo)+uplus([-1 1]) mima(la)+uplus([-1 1])]);
z=interp2(elo,ela,elev,lo,la,METHOD);

%%%%erock(x,-z,[],'o');
