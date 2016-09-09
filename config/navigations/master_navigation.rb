SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'
  navigation.active_leaf_class = 'nav-active-leaf'
  navigation.items do |primary|    
    primary.item  :storage,
                  'Storage',
                  nil,
                  html: { class: 'fancy-nav-header', :'data-icon' => 'storage-icon' },
                  if: -> { services.available?(:object_storage, :containers) } do |storage_nav|
      storage_nav.item  :shared_storage,
                        'Shared Object Storage',
                        -> { plugin('object_storage').entry_path },
                        highlights_on: -> { params[:controller][%r{object_storage/?.*}] }
    end

    primary.item  :monitoring,
                  'Monitoring', nil,
                  html: { class: 'fancy-nav-header', :'data-icon' => 'monitoring-icon' },
                  if: -> { plugin_available?(:monitoring) } do |monitoring_nav|
      monitoring_nav.item :monitoring,
                          'Monitoring',
                          -> { plugin('monitoring').entry_path },
                          if: -> { plugin_available?(:monitoring) },
                          highlights_on: -> { params[:controller][%r{monitoring/?.*}] }
    end

    primary.item  :access_management,
                  "Authorizations for project #{@scoped_project_name}",
                  nil,
                  html: { class: 'fancy-nav-header', :'data-icon' => 'access_management-icon' },
                  if: lambda {
                    services.available?(:identity) &&
                      current_user                 &&
                      (
                        current_user.is_allowed?('identity:project_member_list') ||
                        current_user.is_allowed?('identity:project_group_list')
                      )
                  } do |access_management_nav|
      access_management_nav.item  :user_role_assignments,
                                  'User Role Assignments',
                                  -> { plugin('identity').projects_members_path },
                                  if: -> { current_user.is_allowed?('identity:project_member_list') },
                                  highlights_on: %r{identity/projects/members/?.*}
      access_management_nav.item  :group_management,
                                  'Group Role Assignments',
                                  -> { plugin('identity').projects_groups_path },
                                  if: -> { current_user.is_allowed?('identity:project_group_list') },
                                  highlights_on: %r{identity/projects/groups/?.*}
    end
        

    primary.dom_attributes = { class: 'fancy-nav', role: 'menu' }
  end
end
