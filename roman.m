function s=roman(i)
% ROMAN		Roman numeral from (Arabic) number
%
% s = roman(i)
%
% i	= single numeric input
% s	= string of roman numeral (all caps)
%
% After 3000, further M's are just added, although higher numbers should
% be overlined IV etc.
% 
% See also CHAR


%Time-stamp:<Last updated on 01/11/27 at 11:27:59 by even@gfi.uib.no>
%File:<d:/home/matlab/roman.m>

							% Definitions:
s1={'I','II','III','IV','V','VI','VII','VIII','IX'};	% 1-9
s2={'X','XX','XXX','XL','L','LX','LXX','LXXX','XC'};	% 10-90
s3={'C','CC','CCC','CD','D','DC','DCC','DCCC','CM'};	% 100-900
s4={'M'};						% 1000

i = floor(i);				% Round number

i4= floor(i/1000);			% peel off digits after
i3= floor(i/100);
i2= floor(i/10);

i1=i-i2*10;				% peel off digits before
i2=i2-i3*10;
i3=i3-i4*10;

[n1,n2,n3,n4]=deal('');

if any(i4),	n4=char(repmat(s4,1,i4))';	end	% transform digits
if any(i3),	n3=s3(i3);			end
if any(i2),	n2=s2(i2);			end
if any(i1),	n1=s1(i1);			end	

s=strcat(n4,n3,n2,n1);
