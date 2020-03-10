% TESTMATS      generates a simple matrix and vector for function tests
if exist('tm')|exist('tv')
  disp('There are already objects named tm and tv!')
  svar=input('Do you want to overwrite? y/n (n) ','s');
else
  svar='y';
end
if findstr(svar,'y')%|~isempty(svar)
  disp('Testobjects are:')
  ta=reshape(1:24,3,4,2)	% array
  tm=reshape(1:12,3,4)		% matrix
  tv=reshape(1:3,3,1)		% vector
else
  disp('Nothing done.')
end
clear svar

