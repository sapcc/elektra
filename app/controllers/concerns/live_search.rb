module LiveSearch
  # include Services

  SERVICE_METHOD_MAP = {
    'domain' => %w[identity find_domain],
    'inquiry' => %w[inquiry get_inquiry],
    'group' => %w[identity find_group],
    'os_credential' => %w[identity find_credential],
    'project' => %w[identity find_project],
    'role' => %w[identity find_role],
    'user' => %w[identity find_user],
    'server' => %w[compute find_server all_tenants],
    'flavor' => %w[compute find_flavor all_tenants],
    'flavor_metadata' => %w[compute find_flavor_metadata all_tenants],
    'hypervisor' => %w[compute find_hypervisor all_tenants],
    'keypair' => %w[compute find_keypair all_tenants],
    'volume' => %w[block_storage find_volume all_tenants],
    'snapshot' => %w[block_storage find_snapshot all_tenants],
    'network' => %w[networking find_network],
    'subnet' => %w[networking find_subnet],
    'floatingip' => %w[networking find_floating_ip],
    'port' => %w[networking find_port],
    'network_rbac' => %w[networking find_rbac],
    'router' => %w[networking find_router],
    'security_group' => %w[networking find_security_group],
    'security_group_rule' => %w[networking find_security_group_rule],
    'node' => %w[automation node],
    'automation_job' => %w[automation job],
    'automation' => %w[automation automation],
    'automation_run' => %w[automation automation_run],
    'zone' => %w[dns_service find_zone all_projects],
    'pool' => %w[dns_service find_pool all_projects],
    'image' => %w[image find_image],
    'secret' => %w[key_manager find_secret],
    'container' => %w[key_manager find_container],
    'loadbalancer' => %w[loadbalancing find_loadbalancer],
    'lb_listener' => %w[loadbalancing find_listener],
    'lb_pool' => %w[loadbalancing find_pool],
    'lb_healthmonitor' => %w[loadbalancing find_healthmonitor],
    'storage_container' => %w[object_storage container_metadata],
    'share' => %w[shared_filesystem_storage find_share all_tenants],
    'share_network' => %w[shared_filesystem_storage find_share_network all_tenants],
    'share_snapshot' => %w[shared_filesystem_storage snapshots_detail all_tenants],
    'share_security_service' => %w[shared_filesystem_storage find_security_service all_tenants]
  }.freeze

  def live_search(service_manager, term, options = {})
    object_type = options[:object_type]

    service_name, method_name, all_projects_param = service_and_method_name(
      object_type
    )

    raise StandardError, "#{object_type} is not supported." unless service_name

    # service = object_service(service_name)
    service = service_manager.send(service_name) if service_manager.respond_to?(service_name)

    raise StandardError, "Service #{service_name} not found." unless service

    object = service.send(method_name, term)
    render json: [object] && return if object

    filter = { name: term }
    filter[all_projects_param] = true if all_projects_param
    service.send(object_type.pluralize, filter)
  end

  protected

  # def object_service(name)
  #   return nil unless cloud_admin.respond_to?(name)
  #   cloud_admin.send(name)
  # end

  def service_and_method_name(object_type)
    SERVICE_METHOD_MAP[object_type]
  end
end
