function ticksign(akse,h)
% TICKSIGN      switches the sign of ticklabels (+/-)
% on the given axis (akse)
%
% ticksign(akse,h)
%
% akse   = character 'x', 'y' or 'z' (default='y') 
% h = axis handle for operation on other axes than the current

%Time-stamp:<Last updated on 03/02/22 at 17:48:42 by even@gfi.uib.no>
%File:</home/janeven/matlab/evenmat/ticksign.m>

error(nargchk(0,2,nargin));
if nargin<2|isempty(h)
  h=gca;
end
if nargin<1|isempty(akse)
  akse='y';
end

if ~ischar(akse),error('Argument needs to be ''x'', ''y'' or ''z''!');end

if     findstr(akse,'x'); akse='X'; % anything with x in it
elseif findstr(akse,'y'); akse='Y';
elseif findstr(akse,'z'); akse='Z';
end

eval([ 'tck=get(h,''',akse,'tick'');' ])
eval([ 'lab=get(h,''',akse,'ticklabel'');' ])

if iscell(lab), N=length(lab);
else		N=1;		end

for i=1:N
  if N>1, tcki=tck{i}; labi=lab{i};
  else tcki=tck; labi=lab;		end
  int2str(tcki(1));
  if ans(1)==labi(1)
    %eval([ 'set(h(i),''',akse,'TickLabel'',-tcki)' ]) % OK in 5.3
    eval([ 'set(h(i),''',akse,'TickLabel'',num2str(-tcki''))' ])
  else
    eval([ 'set(h(i),''',akse,'TickLabel'',num2str(tcki''))' ]) 
  end
  % Some sort of R13 or unix bug makes -0 (!) in the first case above
end
eval([ 'set(h,''',akse,'Tickmode'',''manual'')' ]) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return

% another variant:
eval([ 'lab=get(h,''',akse,'ticklabel'')' ])
for i=1:length(lab(:,1))
  if findstr(lab(i,1),'-')
    lab(i,1) = ' ';
    %    labl(i,findstr(lab(i,:),'-'))=' '
    %    labl(i,1:length(lab(i,:)))=lab(i,2:length(lab(i,:)))
  elseif findstr(lab(i,1),' ')
    lab(i,1)= '-';
  elseif ~findstr(lab(i,1),'0')
    lab=cellstr(lab);
    lab(i)=strcat('-',lab(i));
    lab=char(lab);
    %labl(i)=strcat('-',cellstr(lab(i,:)))
    %labl(i,:)=strcat(char('-'),lab(i,:))
  end      
end

lab=cellstr(lab);
eval([ 'set(h,''',akse,'ticklabel'',lab);' ])
lab


