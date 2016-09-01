SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'
  navigation.active_leaf_class = 'nav-active-leaf'
  navigation.items do |primary|
    primary.item :networking,
                 'Networking',
                 nil,
                 html: { class: 'fancy-nav-header', :'data-icon' => 'networking-icon' },
                 if: -> { plugin_available?(:dns_service) } do |networking_nav|
      networking_nav.item :dns_service,
                          'DNS',
                          -> { plugin('dns_service').zones_path },
                          if: -> { plugin_available?(:dns_service) },
                          highlights_on: -> { params[:controller][%r{dns_service/?.*}] }
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
