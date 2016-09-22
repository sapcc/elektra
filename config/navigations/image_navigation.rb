SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'
  navigation.active_leaf_class = 'nav-active-leaf'
  navigation.items do |primary|

    primary.item :api, 
                 'API Access', nil, 
                 html: {class: "fancy-nav-header", 'data-icon': "api-icon"},
                 if: -> {services.available?(:webconsole)} do |api_nav|
      api_nav.item :web_console,
                   'Web Console', -> { plugin('webconsole').root_path}, 
                   if: -> { services.available?(:webconsole)},
                   highlights_on: Proc.new { params[:controller][/webconsole\/.*/] }
      api_nav.item :api_endpoints, 
                   'API Endpoints for Clients', -> { plugin('identity').projects_api_endpoints_path}
    end

    primary.item  :compute,
                  'Compute',
                  nil,
                  html: { class: 'fancy-nav-header', :'data-icon' => 'compute-icon' },
                  if: lambda {
                    services.available?(:image, :os_images)
                  } do |compute_nav|
      compute_nav.item  :images,
                        'Images',
                        -> { plugin('image').os_images_public_index_path },
                        highlights_on: -> { params[:controller][%r{image/?.*}] }
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
