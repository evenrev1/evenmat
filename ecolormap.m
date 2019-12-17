function [cmap,cont] = ecolormap(cont,cm1,cm2,cont0)
% ECOLORMAP	Discrete colourmap with different resolutions.
% Made in order to have a simple way to provide different colour
% resolution in multicolour graphics such as contourf, as well as a
% simple way to combine two different colourmaps into one.
% 
% [cmap, cont] = ecolormap(cont,cm1,cm2,cont0)
% 
% cont	= contour/level specification in the same unit as the plotted
%	  variable. Can consist of two parts with different increments. 
% cm1	= String with name of colourmap to use or numeric matrix
%	  containing an RGB-colourmap. 
% cm2	= Same as cm1, but for the second part of cont. (Optional.)
%	  If provided, cm1 is used for the first part of cont, and cm2
%	  for the latter.  
%	  (See below for details.)  
% cont0 = In case of uniform cont, but two colourmaps, the contour
%         level between the two maps can be given as single value
%         here (a number in cont). (default = the middle contour)
%
% cmap	= The resulting colourmap for the whole range of cont.
% cont	= The matching contour spec (with any input duplicates removed). 
%
% If no output is requested, the resulting colour map and color range of
% cont is applied to the current figure, and ticks of any existing
% colorbar is set to cont.
%
% The basic principle is to match up two parts of (contour) level
% specification with two colour maps, carefuly matching the ratio of
% ranges in variable space and ratio of lengths of colourmaps.
%
% CONTOUR SPECIFICATION is best built using LINSPACE, but there are
% several ways. For example:
%
% cont = [linspace(-4,0,17) linspace(0,7,8)];	
% cont = [-4:0.25:0 0:7];
% cont = [-4:1/4:0 0:7];
%
% Duplicate numbers, like the zeros in this example, are ignored. These
% examples alle give the same cont, consisting of one part with
% increments of 0.25 and a second part with increments of 1. These are
% the two parts the two colormaps will be matched to. There is great
% flexibility in the choice of increments. The increments of one part
% does not necessarily have to be a fraction of the other. However,
% there can only be two different increment sizes. Note also that
% LINSPACE's 3rd input is the number of values to distribute, i.e., one
% more than the number of increments.
%
% COLOURMAP SPECIFICATIONS can be easily given as known names of
% existing colourmaps, such as those of CMOCEAN (see CMOCEAN) or
% M_COLMAP (see M_COLMAP) or the standard Matlab maps (see
% GRAPH3D). This is the sequence of priority in case of conflict of
% naming.  You can also input your own RGB matrices, but these must have
% the exact same number of colours (rows) as the number of increments in
% the part of cont they are assigned to.
%
% If only one (or no) colormap is input, it is assumed that it (or the
% default, parula) should cover the whole range of cont. It is only the
% levels of cont that is applied then. Only string input of colormap
% name is allowed in this case.  Note that the colormap is no longer
% linear along the physical axis, only stepwise between levels. This
% gives discernible colors when high resolution is demanded.
% 
% EXAMPLES OF USE:
% figure(1); peaks; colorbar; 
% ecolormap(cont);			% Applies cont w/default map
% ecolormap(cont,'jet');		% Applies cont with jet map
% ecolormap(cont,hsv(23));		% How to use RGB input
% ecolormap(cont,'winter','cool');	% Two maps, one for each part
% ecolormap(cont,'-tempo','speed');	% Two maps from CMOCEAN
%
% Recommended reading:
% - The CMOCEAN colormaps for oceanography:
% https://matplotlib.org/cmocean/
% - The CET Perceptually Uniform Colour Maps toolbox at
% http://peterkovesi.com/projects/colourmaps/
% - Colorbrewer. Where you can visually make your own colourmaps
% interactively and export to rgb, cmyk, and hex, or get CBREWER for
% Matlab. http://colorbrewer2.org
%
% For a list of some colourmap names, type TYPE ECOLORMAP.
%
% See also CMOCEAN M_COLMAP GRAPH3D COLORCET LINSPACE COLORMAP ECOLORBAR

% This is ECOLORMAP Version 0.9 (Beta)

% ------------------------------------------------------------------------
% A list of colourmaps is not provided in the help text, for
% compatibility with further development in M_COLORMAP and
% CMOCEAN. Hence also, the use of try/catch. But here are the names as
% of 2019.03.06:
%
% CMOCEAN:
% SEQUENTIAL:                DIVERGING: 
% 'thermal'                  'balance'
% 'haline'                   'delta'
% 'solar'                    'curl'
% 'ice'
% 'gray'                     CONSTANT LIGHTNESS:
% 'oxy'                      'phase'
% 'deep'
% 'dense'
% 'algae'
% 'matter'
% 'turbid'
% 'speed'
% 'amp'
% 'tempo'
%
% M_COLMAP:
%   'jet' : a percentually uniform variation of the JET colormap. It 
%           contains the multiple colours which make JET useful, while 
%           avoiding the weird highlighting especially around yellow and 
%           cyan. The colors begin with dark blue, range through shades 
%           of blue, green, orange and red, and ends with dark red. 
%   'blue' : a perceptually useful blue shading (good for bathymetry)
%   'green' : a precentually useful green shading
%   'diverging' : a blue/red diverging colormap
%
% MATLAB:
% parula     - Blue-green-orange-yellow color map
% hsv        - Hue-saturation-value color map.
% hot        - Black-red-yellow-white color map.
% gray       - Linear gray-scale color map.
% bone       - Gray-scale with tinge of blue color map.
% copper     - Linear copper-tone color map.
% pink       - Pastel shades of pink color map.
% white      - All white color map.
% flag       - Alternating red, white, blue, and black color map.
% lines      - Color map with the line colors.
% colorcube  - Enhanced color-cube color map.
% vga        - Windows colormap for 16 colors.
% jet        - Variant of HSV.
% prism      - Prism color map.
% cool       - Shades of cyan and magenta color map.
% autumn     - Shades of red and yellow color map.
% spring     - Shades of magenta and yellow color map.
% winter     - Shades of blue and green color map.
% summer     - Shades of green and yellow color map.
% ------------------------------------------------------------------------

error(nargchk(1,4,nargin));
if nargin<4 | isempty(cont0),	cont0=[];	end
if nargin<3 | isempty(cm2),	cm2='hold';	end
if nargin<2 | isempty(cm1),	cm1='parula';	end

infl=logical(1); % To inflate size of colourmaps to match ranges.

% ------- Test contour specs ---------------------------------------------
%cont=[-2:.25:0 1:6];		% a trivial example
%cont=[-2:.33333:0 1:6];	% does not hit 0
%cont=[-2:.15:0 1:6];		% does not hit 0
%cont=[linspace(-2,0,10) 1:6];	% Correct use of linspace
%cont=[linspace(-2,0,8) linspace(0,6,6)];	% Two zeros!!
%cont=[linspace(-2,0,16) linspace(0,6,8)];	% Two zeros!!
%cont=[linspace(-2,4,6) linspace(4,6,8)];	% Two zeros!!
%cont=[linspace(-2,2,5) linspace(2,6,5)];	% Same steps 
%cont=[linspace(-2,0,9) linspace(0,6,7)];	% Two zeros!!
 
cont=unique(cont);	% To avoid overlaps, like the two zeros above.

% ------- Analyse the suggested levels -----------------------------------
[dx,ia1,ic1] = unique(round(diff(cont),10),'stable'); % some flexibility
% dx are the different increments in cont (should be only two)
steps=length(ia1); 

x=diff(cont([ia1;end]));	% The length of each part
n=round(x./dx);			% The number of colours needed in
                                % each part. By construct n is an
                                % integer. ROUND only to make it
                                % integer type.

% ------- Test for number of parts in cont -------------------------------
if steps>2
  error(['Only two different increment-sizes allowed! The use of LINSPACE is recommended.']);
elseif steps<2		% uniform cont
  infl=logical(0);
  if isempty(cont0), cont0=floor(n/2);	% find mid point
  else cont0=find(cont==cont0)-1, end	% translate from value to index 
  n=[cont0,n-cont0];			% make two-part n
end

if strcmp(cm2,'hold')
  % ------- Make one colormap for the whole range ------------------------
  N=n(1)+n(2);
  if isnumeric(cm1)			% Own colourmap used
    if size(cm1,1)~=N
      error('Number of colours does not match number of increments in part one!'); 
    else  
      cm=cm1;
    end
  else
    try
      cm=cmocean(cm1,N);		% Try using CMOCEAN
    catch
      try
	cm=m_colmap(cm1,N);		% Try using M_MAP
      catch
	try
	  eval(['cm=',cm1,'(N);']);	% Use regular matlab colormaps
	catch
	  cm=parula(N);			% In case of nonsense input
	end
      end
    end
  end
  cm1=cm(1:n(1),:); cm2=cm(n(1)+1:end,:);
  % Note that the colormap is no longer linear along the axis, only
  % between levels. 
else
  % ------- Make the colormaps based on the number of colours needed -----
  % ------- First part ---------------------------------------------------
  if isnumeric(cm1)			% Own colourmap used
    if n(1)~=size(cm1,1)
      error('Number of colours does not match number of increments in part one!'); 
    end
  else			
    try 
      cm1=cmocean(cm1,n(1));		% Try using CMOCEAN
    catch  
      try
	cm1=m_colmap(cm1,n(1));		% Try using M_MAP
      catch
	try
	  eval(['cm1=',cm1,'(n(1));']);	% Use regular matlab colormaps
	catch
	  cm1=cool(n(1));		% In case of nonsense input
	end
      end
    end
  end
  % ------- Second part ---------------------------------------------------
  if isnumeric(cm2)			% Own colourmap used
    if n(2)~=size(cm2,1)
      error('Number of colours does not match number of increments in part two!'); 
    end
  else
    try 
      cm2=cmocean(cm2,n(2));		% Try using CMOCEAN
    catch
      try
	cm2=m_colmap(cm2,n(2));		% Try using M_MAP
      catch
	try
	  eval(['cm2=',cm2,'(n(2));']);	% Use regular matlab colormaps
	catch
	  cm2=jet(n(2));		% In case of nonsense input
	end
      end
    end
  end
end

if infl
  % ------- Inflate the colormaps to the proper ratio --------------------
  % The two RGB matrices need to have the same ratio of size as the
  % ratio of the two parts in physical parameter space. 
  %
  % First, two integers need to be found, by which the respective
  % colormaps are to be inflated by. The calculations behind this is 
  %
  % x1/x2 = n1*i/n2*j  &  n=x/dx  =>
  %
  % x1/x2 = x1/dx1*i / x2/dx2*j <=> i*dx2 / j*dx1 = 1 <=> i=dx1/dx2*j
  %
  % where n1 and n2 are the numbers of colors found above, and i and j
  % the integers to inflate the colormaps by. These are found by
  % iteratively increasing one of them, with a constraint on when the
  % other is considered close enough to an integer value:
  %
  if dx(2)>dx(1)
    j=0; i=0.1;
    while abs(round(i)-i)>1e-4
      j=j+1;
      i=dx(1)/dx(2)*j;
    end
    i=round(i); 
  elseif dx(2)<dx(1)
    i=0; j=0.1;
    while abs(round(j)-j)>1e-4
      i=i+1;
      j=dx(2)/dx(1)*i;
    end
    j=round(j); 
  end
  % Second, the colourmaps are duplicated sideways by REPMAT,
  % transposed, and stacked by RESHAPE.
  cm1=reshape(repmat(cm1,1,i)',3,n(1)*i)';
  cm2=reshape(repmat(cm2,1,j)',3,n(2)*j)';
end

% ------- Combine the two colourmaps -------------------------------------
cmap=[cm1;cm2];	

if nargout==0
  % ------- Set the properties of the current figure ---------------------
  colormap(cmap);
  caxis([min(cont) max(cont)]);
  set(findobj(gcf,'tag','Colorbar'),'Ticks',cont);
end


