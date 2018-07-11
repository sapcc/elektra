module ApiLookup
  # include Services

  SERVICE_METHOD_MAP = {
    'domain' => ['identity', 'find_domain(":term")', 'domains(name: ":term")'],
    'inquiry' => ['inquiry', 'get_inquiry(":term")'],
    'group' => ['identity', 'find_group(":term")', 'groups(name: ":term")'],
    'os_credential' => ['identity',
                        'find_credential(":term")',
                        'credentials(user_id: ":term")',
                        'credentials(type: ":term")'],
    'project' => ['identity',
                  'find_project(":term")',
                  'projects(name: ":term")'],
    'role' => ['identity', 'find_role(":term")', 'roles(name: ":term")'],
    'user' => ['identity', 'find_user(":term")', 'users(name: ":term")'],
    'server' => ['compute', 'find_server(":term")',
                 'servers(name: ":term", all_tenants: true)'],
    'flavor' => ['compute', 'find_flavor(":term")',
                 'flavors(name: ":term", all_tenants: true)'],
    'flavor_metadata' => ['compute', 'find_flavor_metadata(":term")'],
    'hypervisor' => ['compute', 'find_hypervisor(":term")',
                     'hypervisors(name: ":term", all_tenants: true)'],
    'keypair' => ['compute', 'find_keypair(":term")'],
    'volume' => ['block_storage', 'find_volume(":term")',
                 'volumes(name: ":term", all_tenants: true)'],
    'snapshot' => ['block_storage', 'find_snapshot(":term")',
                   'snapshots(name: ":term", all_tenants: true)'],
    'network' => ['networking', 'find_network(":term")',
                  'networks(name: ":term")'],
    'subnet' => ['networking', 'find_subnet(":term")',
                 'subnets(name: ":term")',
                 'subnets(network_id: ":term")'],
    'floatingip' => ['networking', 'find_floating_ip(":term")',
                     'floating_ips(floating_ip_address: ":term")'],
    'port' => ['networking', 'find_port(":term")', 'ports(name: ":term")',
               'ports(fixed_ips: "ip_address=:term")'],
    'network_rbac' => ['networking', 'find_rbac(":term")',
                       'rbacs(object_id: ":term")',
                       'rbacs(object_type: ":term")'],
    'router' => ['networking', 'find_router(":term")',
                 'routers(name: ":term")'],
    'security_group' => ['networking', 'find_security_group(":term")',
                         'security_groups(name: ":term")'],
    'security_group_rule' => ['networking', 'find_security_group_rule(":term")',
                              'security_group_rules(protocol: ":term")',
                              'security_group_rules(direction: ":term")',
                              'security_group_rules(remote_group_id: ":term")'],
    'node' => ['automation', 'node(":term")'],
    'automation_job' => ['automation', 'job(":term")'],
    'automation' => ['automation', 'automation(":term")'],
    'automation_run' => ['automation', 'automation_run(":term")'],
    'zone' => ['dns_service', 'find_zone(":term")',
               'zones(name: ":term", all_projects: true)'],
    'pool' => ['dns_service', 'find_pool(":term")',
               'pools(name: ":term", all_projects: true)'],
    'recordset' => ['dns_service', 'find_recordset(":term")',
                    'recordsets(name: ":term", all_projects: true)',
                    'recordsets(type: ":term", all_projects: true)'],
    'image' => ['image', 'find_image(":term")', 'images(name: ":term")'],
    'secret' => ['key_manager', 'find_secret(":term")',
                 'secrets(name: ":term")'],
    'container' => ['key_manager', 'find_container(":term")',
                    'containers(name: ":term")'],
    'loadbalancer' => ['loadbalancing', 'find_loadbalancer(":term") ',
                       'loadbalancers(name: ":term")'],
    'lb_listener' => ['loadbalancing', 'find_listener(":term")',
                      'listeners(name: ":term")'],
    'lb_pool' => ['loadbalancing', 'find_pool(":term")',
                  'pools(name: ":term")'],
    'lb_healthmonitor' => ['loadbalancing', 'find_healthmonitor(":term")',
                           'healthmonitors(name: ":term")'],
    'storage_container' => ['object_storage', 'container_metadata(":term")'],
    'share' => ['shared_filesystem_storage ', 'find_share(":term")',
                'shares(name: ":term", all_tenants: true)'],
    'share_network' => ['shared_filesystem_storage',
                        'find_share_network(":term")',
                        'share_networks(name: ":term", all_tenants: true)'],
    'share_snapshot' => ['shared_filesystem_storage',
                         'snapshots_detail(":term")',
                         'snapshots(name: ":term", all_tenants: true)'],
    'share_security_service' => [
      'shared_filesystem_storage',
      'find_security_service(":term")',
      'security_services(name: ":term", all_tenants: true)'
    ]
  }.freeze

  # This method tries to find an object by id or name via API
  def api_search(service_manager, object_type, term)
    service_name, methods = service_and_methods(object_type)

    # service = object_service(service_name)
    unless service_manager.respond_to?(service_name)
      raise StandardError, "Service #{service_name} could not be found."
    end
    service = service_manager.send(service_name)

    methods.each do |m|
      method = m.gsub(':term', term)
      found_items = eval("service.#{method}")

      if found_items
        items = if found_items.is_a?(Hash)
                  found_items[:items]
                elsif found_items.is_a?(Array)
                  found_items
                else
                  [found_items]
                end
        return { items: items, service_call: "#{service_name}->#{method}" }
      end
    end

    { items: [], service_call: '' }
  end

  def service_and_methods(object_type)
    object_service_values = SERVICE_METHOD_MAP[object_type]
    if object_service_values.blank?
      raise StandardError, "#{object_type} is not supported."
    end

    [object_service_values.first, object_service_values[1..-1]]
  end
end
