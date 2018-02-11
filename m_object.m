function m_object(dir)
% M_OBJECT	Storage of M_MAP parameters in axes' 'UserData'
%
% m_object(dir)
%
% dir	= 'in'  puts current MAP_PROJECTION and MAP_VAR_LIST into current
%               axes' userdata  
%         'out' puts current axes' userdata into MAP_PROJECTION and
%               MAP_VAR_LIST

if nargin>0|~isempty(dir)
  global MAP_PROJECTION MAP_VAR_LIST 
  switch dir
   case 'in'
    udata.projection=MAP_PROJECTION;
    udata.var_list=MAP_VAR_LIST;
    set(gca,'userdata',udata,'tag','m_map');
   case 'out'
    udata=get(gca,'userdata');
    MAP_PROJECTION=udata.projection	% These are global but not 
    MAP_VAR_LIST=udata.var_list		% defined in base (workspace)
    % All the handles (the numbers) are new when loading image:
    MAP_VAR_LIST.name.handles_all=findobj(gca,'tag','m_name');
    MAP_VAR_LIST.name.handles=findobj(MAP_VAR_LIST.name.handles_all,...
				      'visible','on');
    MAP_VAR_LIST.name.boxhandle=findobj(gcf,'tag','m_listbox');
  end
end
