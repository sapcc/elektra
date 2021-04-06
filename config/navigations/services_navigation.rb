# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  # Specify a custom renderer if needed.
  # The default renderer is SimpleNavigation::Renderer::List which renders HTML lists.
  # The renderer can also be specified as option in the render_navigation call.
  # navigation.renderer = Your::Custom::Renderer

  # Specify the class that will be applied to active navigation items. Defaults to 'selected'
  navigation.selected_class = 'active'

  # Specify the class that will be applied to the current leaf of
  # active navigation items. Defaults to 'simple-navigation-active-leaf'
  navigation.active_leaf_class = 'nav-active-leaf'

  # Specify if item keys are added to navigation items as id. Defaults to true
  # navigation.autogenerate_item_ids = true

  # You can override the default logic that is used to autogenerate the item ids.
  # To do this, define a Proc which takes the key of the current item as argument.
  # The example below would add a prefix to each key.
  # navigation.id_generator = Proc.new {|key| "my-prefix-#{key}"}

  # If you need to add custom html around item names, you can define a proc that
  # will be called with the name you pass in to the navigation.
  # The example below shows how to wrap items spans.
  # navigation.name_generator = Proc.new {|name, item| "<span>#{name}</span>"}

  # Specify if the auto highlight feature is turned on (globally, for the whole navigation). Defaults to true
  # navigation.auto_highlight = true

  # Specifies whether auto highlight should ignore query params and/or anchors when
  # comparing the navigation items with the current URL. Defaults to true
  # navigation.ignore_query_params_on_auto_highlight = true
  # navigation.ignore_anchors_on_auto_highlight = true

  # If this option is set to true, all item names will be considered as safe (passed through html_safe). Defaults to false.
  # navigation.consider_item_names_as_safe = false

  # Define the primary navigation
  navigation.items do |primary|
    # Add an item to the primary navigation. The following params apply:
    # key - a symbol which uniquely defines your navigation item in the scope of the primary_navigation
    # name - will be displayed in the rendered navigation. This can also be a call to your I18n-framework.
    # url - the address that the generated item links to. You can also use url_helpers (named routes, restful routes helper, url_for etc.)
    # options - can be used to specify attributes that will be included in the rendered navigation item (e.g. id, class etc.)
    #           some special options that can be set:
    #           :if - Specifies a proc to call to determine if the item should
    #                 be rendered (e.g. <tt>if: -> { current_user.admin? }</tt>). The
    #                 proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :unless - Specifies a proc to call to determine if the item should not
    #                     be rendered (e.g. <tt>unless: -> { current_user.admin? }</tt>). The
    #                     proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :method - Specifies the http-method for the generated link - default is :get.
    #           :highlights_on - if autohighlighting is turned off and/or you want to explicitly specify
    #                            when the item should be highlighted, you can set a regexp which is matched
    #                            against the current URI.  You may also use a proc, or the symbol <tt>:subpath</tt>.
    #

    primary.item :compute,
                 'Compute',
                 nil,
                 html: { class: 'fancy-nav-header', 'data-icon': 'compute-icon' },
                 if: lambda {
                       services.available?(:compute, :instances) or
                         services.available?(:image, :os_images) or
                         plugin_available?(:block_storage)
                     } do |compute_nav|
      compute_nav.item :instances,
                       'Servers',
                       -> { plugin('compute').instances_path },
                       if: -> { services.available?(:compute, :instances) },
                       highlights_on: proc { params[:controller][%r{compute/instances}] }
      compute_nav.item :block_storage,
                       'Volumes & Snapshots',
                       -> { plugin('block_storage').root_path },
                       if: -> { plugin_available?(:block_storage) },
                       highlights_on: proc { params[:controller][/block_storage/] }
      compute_nav.item :images,
                       'Server Images & Snapshots',
                       lambda {
                         services.image.current_version >= 'v2.5' ? plugin('image').ng_path : plugin('image').os_images_public_index_path
                       },
                       if: -> { services.available?(:image, :os_images) },
                       highlights_on: proc { params[:controller][%r{image/.*}] }
      compute_nav.item :flavors,
                       'Flavors',
                       -> { plugin('compute').flavors_path },
                       if: -> { plugin_available?(:compute) },
                       highlights_on: -> { params[:controller][%r{flavors/?.*}] }
    end

    primary.item :containers,
                 'Containers',
                 nil, html: { class: 'fancy-nav-header', 'data-icon': 'containers-icon' },
                      if: lambda {
                            plugin_available?(:kubernetes) &&
                              current_user &&
                              current_user.has_service?('kubernikus')
                          } do |containers_nav|
      containers_nav.item :kubernetes,
                          'Kubernetes',
                          -> { plugin('kubernetes').root_path },
                          if: lambda {
                                plugin_available?(:kubernetes) && current_user && current_user.has_service?('kubernikus')
                              },
                          highlights_on: proc { params[:controller][%r{kubernetes/.*}] }
    end

    primary.item :automation,
                 'Monsoon Automation',
                 nil,
                 html: { class: 'fancy-nav-header', 'data-icon': 'automation-icon' },
                 if: -> { services.available?(:automation, :nodes) } do |automation_nav|
      automation_nav.item :automation,
                          'Automation',
                          -> { plugin('automation').nodes_path },
                          if: -> { services.available?(:automation, :nodes) },
                          highlights_on: proc { params[:controller][%r{automation/.*}] }
    end

    primary.item :hana,
                 'Bare Metal Data Processing & HANA',
                 nil,
                 html: { class: 'fancy-nav-header', 'data-icon': 'hana-icon' },
                 if: -> { services.available?(:bare_metal_hana, :nodes) } do |bare_metal_hana_nav|
      bare_metal_hana_nav.item :bare_metal_hana,
                               'HANA Servers',
                               -> { plugin('bare_metal_hana').entry_path },
                               if: -> { services.available?(:bare_metal_hana, :nodes) },
                               highlights_on: proc { params[:controller][%r{bare_metal_hana/.*}] }
    end

    primary.item :api,
                 'API Access',
                 nil,
                 html: { class: 'fancy-nav-header', 'data-icon': 'api-icon' } do |api_nav|
      api_nav.item :web_console,
                   'Web Shell',
                   -> { plugin('webconsole').root_path },
                   if: lambda {
                         services.available?(:webconsole) && current_user && current_user.is_allowed?('webconsole:application_get')
                       },
                   highlights_on: proc { params[:controller][%r{webconsole/.*}] }
      api_nav.item :api_endpoints,
                   'API Endpoints for Clients',
                   -> { plugin('identity').projects_api_endpoints_path }
    end

    primary.item :access_management,
                 'Authorizations',
                 nil,
                 html: { class: 'fancy-nav-header', 'data-icon': 'access_management-icon' },
                 if: lambda {
                       services.available?(:identity) and
                         current_user && (
                           current_user.is_allowed?('identity:project_member_list') or
                           (current_user && current_user.is_allowed?('identity:project_group_list'))
                         )
                     } do |access_management_nav|
      access_management_nav.item :user_role_assignments,
                                 'User Role Assignments',
                                 -> { plugin('identity').projects_role_assignments_path },
                                 if: -> { current_user.is_allowed?('identity:project_member_list') },
                                 highlights_on: %r{identity/projects/members/?.*}
      access_management_nav.item :group_management,
                                 'Group Role Assignments',
                                 -> { plugin('identity').projects_role_assignments_path(active_tab: 'groupRoles') },
                                 if: -> { current_user.is_allowed?('identity:project_group_list') },
                                 highlights_on: %r{identity/projects/groups/?.*}
      access_management_nav.item :key_manager,
                                 'Key Manager',
                                 -> { plugin('key_manager').secrets_path },
                                 if: -> { services.available?(:key_manager) },
                                 highlights_on: proc { params[:controller][%r{key_manager/.*}] }
    end

    primary.item :networking,
                 'Networking & Loadbalancing',
                 nil,
                 html: { class: 'fancy-nav-header', 'data-icon': 'networking-icon' },
                 if: lambda {
                       plugin_available?(:networking) ||
                         plugin_available?(:loadbalancing) ||
                         plugin_available?(:dns_service)
                     } do |networking_nav|
      networking_nav.item :networks,
                          'Networks & Routers',
                          -> { plugin('networking').networks_external_index_path },
                          if: -> { plugin_available?(:networking) },
                          highlights_on: %r{networking/(networks|routers)/?.*}
      networking_nav.item :backup_networks,
                          'Backup Networks',
                          -> { plugin('networking').backup_networks_path },
                          if: -> { plugin_available?(:networking) },
                          highlights_on: %r{networking/(backup_networks)/?.*}
      networking_nav.item :ports,
                          'Fixed IPs / Ports',
                          -> { plugin('networking').widget_ports_path },
                          if: -> { plugin_available?(:networking) },
                          highlights_on: %r{networking/ports/?.*}
      networking_nav.item :floating_ips,
                          'Floating IPs',
                          -> { plugin('networking').floating_ips_path },
                          if: -> { plugin_available?(:networking) },
                          highlights_on: %r{networking/floating_ips/?.*}
      networking_nav.item :security_groups,
                          'Security Groups',
                          -> { plugin('networking').widget_security_groups_path },
                          if: -> { plugin_available?(:networking) },
                          highlights_on: %r{networking/security-groups/?.*}
      networking_nav.item :loadbalancing,
                          'Load Balancers',
                          -> { plugin('lbaas2').root_path() },
                          if: -> { plugin_available?(:lbaas2) && services.available?(:lbaas2) },
                          highlights_on: -> { params[:controller][%r{lbaas2/?.*}] }
      networking_nav.item :dns_service,
                          'DNS',
                          -> { plugin('dns_service').zones_path },
                          if: -> { plugin_available?(:dns_service) && services.available?(:dns_service) },
                          highlights_on: -> { params[:controller][%r{dns_service/?.*}] }
    end

    primary.item :storage,
                 'Storage',
                 nil,
                 html: { class: 'fancy-nav-header', 'data-icon': 'storage-icon' },
                 if: -> { services.available?(:object_storage, :containers) } do |storage_nav|
      storage_nav.item :shared_storage,
                       'Shared Object Storage',
                       -> { plugin('object_storage').entry_path },
                       if: -> { services.available?(:object_storage, :containers) },
                       highlights_on: proc { params[:controller][%r{object_storage/.*}] }
      storage_nav.item :shared_filesystem_storage,
                       'Shared File System Storage',
                       -> { plugin('shared_filesystem_storage').start_path('shares') },
                       if: lambda {
                             services.available?(:shared_filesystem_storage) and current_user.is_allowed?('shared_filesystem_storage:application_get')
                           },
                       highlights_on: proc { params[:controller][%r{shared_filesystem_storage/.*}] }
      storage_nav.item :container_image_registry,
                       'Container Image Registry',
                       -> { plugin('keppel').start_path },
                       if: -> { services.available?(:keppel) },
                       highlights_on: proc { params[:controller][%r{keppel/.*}] }
    end

    primary.item :resource_management,
                 'Capacity, Masterdata & Metrics',
                 nil,
                 html: { class: 'fancy-nav-header', 'data-icon': 'monitoring-icon' },
                 if: lambda {
                       services.available?(:resources) or
                         services.available?(:masterdata_cockpit) or
                         plugin_available?(:metrics) or
                         plugin_available?(:audit) or
                         plugin_available?(:reports)
                     } do |monitoring_nav|
      monitoring_nav.item :resources,
                          'Resource Management ',
                          -> { plugin('resources').project_path },
                          if: -> { services.available?(:resources) },
                          highlights_on: proc { params[:controller][%r{resources/.*}] }
      monitoring_nav.item :masterdata_cockpit,
                          'Masterdata',
                          -> { plugin('masterdata_cockpit').project_masterdata_path },
                          if: -> { services.available?(:masterdata_cockpit) },
                          highlights_on: proc { params[:controller][%r{masterdata_cockpit/.*}] }
      monitoring_nav.item :metrics,
                          'Metrics',
                          -> { plugin('metrics').index_path },
                          if: -> { plugin_available?(:metrics) },
                          highlights_on: proc { params[:controller][%r{metrics/.*}] }
      monitoring_nav.item :audit,
                          'Audit',
                          -> { plugin('audit').root_path },
                          if: -> { plugin_available?(:audit) },
                          highlights_on: -> { params[:controller][%r{audit/?.*}] }
      monitoring_nav.item :reports,
                          'Cost Report',
                          -> { plugin('reports').project_cost_index_path },
                          if: -> { plugin_available?(:reports) },
                          highlights_on: -> { params[:controller][%r{reports/?.*}] }
    end

    primary.item :services,
                 'Services',
                 nil,
                 html: { class: 'fancy-nav-header', 'data-icon': 'service-icon' },
                 if: -> { services.available?(:email_service) } do |services_nav|
      services_nav.item :email_service,
                        'Email',
                        -> { plugin('email_service').index_path },
                        if: -> { services.available?(:email_service) },
                        highlights_on: -> { params[:controller][%r{email_service/?.*}] }
    end

    primary.item :cc_tools,
                 'Tools',
                 nil,
                 html: { class: 'fancy-nav-header', 'data-icon': 'cloud-admin-icon' },
                 if: -> { current_user.is_allowed?('tools:application_get') } do |cc_tools_nav|
      cc_tools_nav.item :universal_search,
                        'Universal Search',
                        -> { plugin('cc_tools').start_path },
                        if: -> { current_user.is_allowed?('tools:application_get') },
                        highlights_on: -> { params[:controller][%r{tools/?.*}] }
        cc_tools_nav.item :email_service, 
          'Email Service', 
          -> { plugin('email_service').index_path },
          highlights_on: -> { params[:controller][%r{tools/?.*}] }
    end

    primary.item :services,
                 'Services',
                 nil,
                 html: { class: 'fancy-nav-header', 'data-icon': 'service-icon' },
                 if: -> { services.available?(:email_service) },
      services_nav.item :email_service,
                        'Email',
                        -> { plugin('email_service').index_path },
                        highlights_on: -> { params[:controller][%r{tools/?.*}] }
    end

    # Add an item which has a sub navigation (same params, but with block)
    # primary.item :key_2, 'name', url, options do |sub_nav|
    #   # Add an item to the sub navigation (same params again)
    #   sub_nav.item :key_2_1, 'name', url, options
    # end

    # You can also specify a condition-proc that needs to be fullfilled to display an item.
    # Conditions are part of the options. They are evaluated in the context of the views,
    # thus you can use all the methods and vars you have available in the views.
    # primary.item :key_3, 'Admin', url, class: 'special', if: -> { current_user.admin? }
    # primary.item :key_4, 'Account', url, unless: -> { logged_in? }

    # you can also specify html attributes to attach to this particular level
    # works for all levels of the menu
    primary.dom_attributes = { class: 'fancy-nav', role: 'menu' }

    # You can turn off auto highlighting for a specific level
    # primary.auto_highlight = false
  end
end
