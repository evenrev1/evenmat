function xmean=serialmean(x,b)
% SERIALMEAN (unfinished) makes block means of series
% works on columns like MEAN does
%
% xmean=SERIALMEAN(x,b)
%
% x      matrix- or vector of data
% b      integer length of the block
% xmean  dataseries of blockmean data 
%
% See also MEAN

error('unfinished routine!')

N=floor(length(x(:,1))/b); % number of blocks

for i=1:N
  (i*b-b+1:i*b);
  xmean(i,:)=mean(x(ans,:));
end

