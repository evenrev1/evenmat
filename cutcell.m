function nam=cutcell(name) 
% CUTCELL       cuts away 'empty' cells of cellstring vector
nam=name;
for i = 1:length(name)
 if isempty(name{i})
   nam=name(1:i-1);
   return
 end
end
