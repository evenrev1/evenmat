function figzip(f,h,lin)
% FIGZIP        Reduce byte-size of the figure on file
%
% figzip(f,h,lin)
%
% f     = factor to reduce number of datapoints with, 
%         0 < f <= 1.0 (default = 0.5)
% h     = handle to figure to operate on (default = current)
% lin   = handles to specific lines to alter (default = all in figure)
%
% Sometimes simple line plots gets mysteriously byte-consuming when printed
% to file. This can be due to an unneccesarily large number of datapoints
% used to plot the lines. No error on Your part naturally, sometimes the
% underlying data is big, but a reduction of the number of data _used_ to
% plot does not necessarily reduce the quality of the curves, but it reduces
% the bytesize of the printed file severely. FIGZIP reduces the number of
% data in x-, y-, and z-data of lines.
%
% FIGZIP retains the original data in the lines' userdata, and subsequent
% use is always based on this original dataset, not the reduced and
% replotted datapoints from previous FIGZIP-ing. So trial and error is
% possible, just watch the visual appearance of the lines.
% 
% See also FIG FIGFILE FIGLABEL FIGMATCH FIGSTAMP

%Time-stamp:<Last updated on 02/11/27 at 13:54:45 by even@gfi.uib.no>
%File:<d:/home/matlab/figzip.m>

if nargin<1|isempty(f),         f=0.5;                          end
if nargin<2|isempty(h),         h=gcf;                          end
if nargin<3|isempty(lin),       lin=findobj(h,'type','line');   end

M=length(lin);

for i=1:M
  if any(findstr(get(lin(i),'tag'),'figzip'))
    get(lin(i),'userdata');                     % use original data
    x=ans.xdata; y=ans.ydata; z=ans.zdata;
  else
    % first time, use plotting data
    x=get(lin(i),'xdata'); y=get(lin(i),'ydata'); z=get(lin(i),'zdata');
    % save to reconstruct:
    set(lin(i),'userdata',struct('xdata',x,'ydata',y,'zdata',z));
  end  
  step=round(1/f); N=length(x);
  j=unique([1:step:N N]); 
  x=x(j); y=y(j);  
  if ~isempty(z),                                % 3D line
    z=z(j); 
    set(lin(i),'xdata',x,'ydata',y,'zdata',z);
  else                                           % 2D line
    set(lin(i),'xdata',x,'ydata',y);
  end
end
  
addtag('figzip',lin);   


