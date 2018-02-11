function y=nans(varargin)
% NANS          makes matrices filled with NaNs
% just like ZEROS and ONES makes zeros and ones
%
% y = nans(varargin)
%
% See also ONES ZEROS

%Time-stamp:<Last updated on 01/03/20 at 15:18:47 by even@gfi.uib.no>
%File:<d:/home/matlab/nans.m>

%y=ones(varargin{:})*NaN;
y=repmat(NaN,[varargin{:}]);

