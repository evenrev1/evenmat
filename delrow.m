function varargout=delrow(i,varargin);
% DELROW        delete corresponding rows in different matrices
%
% varargout=delrow(i,varargin);
%
% i         = single or vector of integers giving rows to remove
% varargin  = sequence of matrices to have their i-th row(s) removed 
% varargout = the "cleaned" matrices in same order as input

%Time-stamp:<Last updated on 06/12/13 at 21:43:21 by even@nersc.no>
%File:</home/even/matlab/evenmat/delrow.m>

error(nargchk(2,1+length(varargin),nargin));

if ~isint(i) & ~isempty(i)
  error('Integer first argument (row numbers) required!'); 
end

varargin{1};
incli=1:length(ans(:,1));
for ii=1:length(i)       % find indices of rows to keep
  incli=incli(find(incli~=i(ii)));
end  

for i=1:length(varargin)
  var=varargin{i};	% temporary matrix
  var=var(incli,:);	% put in the rows to be kept
  varargout{i}=var;	% replace matrix
end


