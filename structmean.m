function y = structmean(x,field)
% STRUCTMEAN    Average fields of multidimensional structurals
% 
% y = structmean(x,field)
% 
% x     = multidimensional structural
% field = string indicating field to average
%
% y     = mean array of same size as chosen field
% 
% From an array of structurals (multidimensional structure), an
% average of a specified structural field is calculated using
% NANMEAN. Can be handy for calculating mean values of output from
% BIN3D.
%
% EXAMPLE: If               x(1).a = [1 2; 4 5]
%          and              x(2).a = [3 6; 8 9]
%          then  structmean(x,'a') = [2 4; 6 7]
%
% See also NANMEAN STRUCT BIN3D

%Time-stamp:<Last updated on 06/04/19 at 14:56:50 by even@nersc.no>
%File:</Home/even/arbeid/bcm/ncc/map/structmean.m>

if isempty(x) % Check for empty input.
    y = NaN;
    return
end

D=size(getfield(x(1),field));

% reshape into array
%x={x(:).a};
eval(['x={x(:).',field,'};']);
n=length(D);
x=shiftdim(x,-n+1); % n=4=>-3 % n=3=>-2 % n=2=>-1 % n=1=2 (2x1 og 1x2)
X=cell2mat(x);
X=shiftdim(X,n);  % n=4=>4  % n=3=>3  % n=2=>2  % n=1=2 (2x1 og 1x2)
y=nanmean(X);
y=shiftdim(y,1);


