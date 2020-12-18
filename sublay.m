function [m,n]=sublay(O)
% SUBLAY        finds best layout of sublots for given number of plots
% Uses SQRT to find the two nearest numbers with product equal to or
% greater than the input number. This can be utilized for finding the
% best subplot-arrangement for a given number of plots.
%
% [m,n]=sublay(O)
% 
% O     = number of plots to be fitted into the figure
% m     = the smallest of the two factors 
% n     = the greatest of the two factors
%
% Example:      Usage of m as row number gives best fit on a fullscreen
%               figure window and its fullpage landscape printout:
%               [m,n]=sublay(O); subplot(m,n,1);
%
% See also SUBPLOT MULTILABEL CARTOON

error(nargchk(1,1,nargin));
if ~issingle(O) | ~isint(O) | O<1
  error('Single positive integer input only!');
end

m=round(sqrt(O)); 
n=ceil(O/m);


