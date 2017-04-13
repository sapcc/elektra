require 'fog/storage/openstack'

module ResourceManagement
  module Driver
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper

      ##########################################################################
      # new-style interface

      def get_project_data(domain_id, project_id=nil, options={})
        resources = ResourceManagement::Resource.where(domain_id: domain_id)
        resources = resources.where(service: limes_services_to_frontend_services(options[:services])) if options[:services]
        resources = resources.where(name: options[:resources]) if options[:resources]
        if project_id.nil?
          resources = resources.where.not(project_id: nil)
        else
          resources = resources.where(project_id: project_id)
        end

        projects = []
        resources.each do |res|
          next unless res.config # ignore dummy resources
          _, service, resource = locate_entity_service_resource(projects, res.project_id, res.scope_name, res.config)

          service[:scraped_at] = res.updated_at.to_i
          resource[:quota] = res.approved_quota
          resource[:usage] = res.usage
          if res.current_quota != res.approved_quota
            resource[:backend_quota] = res.current_quota
          end
        end

        if project_id.nil?
          return projects
        else
          raise Excon::Errors::NotFound, "project #{project_id} not found" if projects.empty?
          return projects.first
        end
      end

      def get_domain_data(domain_id=nil, options={})
        domain_resources = ResourceManagement::Resource.where(project_id: nil)
        domain_resources = domain_resources.where(service: limes_services_to_frontend_services(options[:services])) if options[:services]
        domain_resources = domain_resources.where(name: options[:resources]) if options[:resources]
        if domain_id.nil?
          domain_resources = domain_resources.where.not(domain_id: nil)
        else
          domain_resources = domain_resources.where(domain_id: domain_id)
        end

        domains = []
        domain_resources.each do |res|
          next unless res.config # ignore dummy resources
          _, _, resource = locate_entity_service_resource(domains, res.domain_id, res.scope_name, res.config)
          resource[:quota] = res.approved_quota
          resource[:usage] = 0
          resource[:projects_quota] = 0
        end

        project_resources = ResourceManagement::Resource.where.not(project_id: nil)
        project_resources = project_resources.where(service: limes_services_to_frontend_services(options[:services])) if options[:services]
        project_resources = project_resources.where(name: options[:resources]) if options[:resources]
        unless domain_id.nil?
          project_resources = project_resources.where(domain_id: domain_id)
        end

        project_resources.group('domain_id,service,name').pluck('domain_id,service,name,SUM(approved_quota),SUM(GREATEST(COALESCE(current_quota, 0), 0)),MIN(updated_at),MAX(updated_at)').each do |values|
          domain_id, service_type, resource_name, sum_approved, sum_nonzero_current, min_updated_at,max_updated_at = values

          service_type = service_type.to_sym
          resource_name = resource_name.to_sym
          resource_config = ResourceManagement::ResourceConfig.all.find { |r| r.service_name == service_type && r.name == resource_name }
          next unless resource_config # ignore dummy resources
          _, service, resource = locate_entity_service_resource(domains, domain_id, nil, resource_config)

          service[:max_scraped_at] = [service[:max_scraped_at], max_updated_at.to_i].reject(&:nil?).max
          service[:min_scraped_at] = [service[:min_scraped_at], min_updated_at.to_i].reject(&:nil?).min
          resource[:quota] ||= 0
          resource[:projects_quota] = sum_approved
          resource[:backend_quota] = sum_nonzero_current if sum_approved != sum_nonzero_current
        end

        project_resources.where('current_quota < 0').group('domain_id,service,name').pluck('domain_id,service,name').each do |values|
          domain_id, service_type, resource_name = values

          service_type = service_type.to_sym
          resource_name = resource_name.to_sym
          resource_config = ResourceManagement::ResourceConfig.all.find { |r| r.service_name == service_type && r.name == resource_name }
          next unless resource_config # ignore dummy resources
          _, _, resource = locate_entity_service_resource(domains, domain_id, resource_config)

          resource[:infinite_backend_quota] = true
        end

        if domain_id.nil?
          return domains
        else
          raise Excon::Errors::NotFound, "domain #{domain_id} not found" if domains.empty?
          return domains.first
        end
      end

      def get_cluster_data(options={})
        resources = ResourceManagement::Resource
        resources = resources.where(service: limes_services_to_frontend_services(options[:services])) if options[:services]
        resources = resources.where(name: options[:resources]) if options[:resources]

        clusters = []

        resources.where(project_id: nil).where.not(domain_id: nil).group('service,name').pluck('service,name,SUM(approved_quota)').each do |values|
          service_type, resource_name, domains_quota = values

          service_type = service_type.to_sym
          resource_name = resource_name.to_sym
          resource_config = ResourceManagement::ResourceConfig.all.find { |r| r.service_name == service_type && r.name == resource_name }
          next unless resource_config # ignore dummy resources
          _, _, resource = locate_entity_service_resource(clusters, "ccloud", nil, resource_config)

          resource[:domains_quota] = domains_quota
        end

        resources.where.not(project_id: nil).group('service,name').pluck('service,name,SUM(usage),MIN(updated_at),MAX(updated_at)').each do |values|
          service_type, resource_name, projects_usage, min_updated_at, max_updated_at = values

          service_type = service_type.to_sym
          resource_name = resource_name.to_sym
          resource_config = ResourceManagement::ResourceConfig.all.find { |r| r.service_name == service_type && r.name == resource_name }
          next unless resource_config # ignore dummy resources
          _, service, resource = locate_entity_service_resource(clusters, "ccloud", nil, resource_config)

          service[:max_scraped_at] = [service[:max_scraped_at], max_updated_at.to_i].reject(&:nil?).max
          service[:min_scraped_at] = [service[:min_scraped_at], min_updated_at.to_i].reject(&:nil?).min
          resource[:usage] = projects_usage
        end

        capacities = ResourceManagement::Capacity
        capacities = capacities.where(service: limes_services_to_frontend_services(options[:services])) if options[:services]
        capacities = capacities.where(resource: options[:capacities]) if options[:capacities]
        if capacities.is_a?(Class)
          capacities = capacities.all
        end

        capacities.each do |capacity|
          next unless capacity.config # ignore dummy capacities (are there any?)
          _, _, resource = locate_entity_service_resource(clusters, "ccloud", nil, capacity.config)

          if capacity.value >= 0
            resource[:capacity] = capacity.value
            resource[:comment]  = capacity.comment || ''
          end
        end

        return clusters.first
      end

      def put_project_data(domain_id, project_id, services)
        quotas = {}

        ResourceManagement::Resource.where(domain_id: domain_id, project_id: project_id).each do |db_res|
          cfg = db_res.config
          srv = services.find { |s| s[:type] == cfg.service.catalog_type.to_sym } or next
          res = srv[:resources].find { |r| r[:name] == cfg.name }                 or next

          db_res.approved_quota = res[:quota]
          db_res.current_quota  = res[:quota]
          next unless db_res.changed?
          db_res.save!

          quotas[db_res.service] ||= {}
          quotas[db_res.service][db_res.name.to_sym] = res[:quota]
        end

        services_with_error = []
        quotas.each do |service, values|
          begin
            set_project_quota(domain_id, project_id, service, values)
          rescue
            services_with_error.append(service.to_s)
          end
        end
        return services_with_error
      end

      def put_domain_data(domain_id, services)
        ResourceManagement::Resource.where(domain_id: domain_id, project_id: nil).each do |db_res|
          cfg = db_res.config
          srv = services.find { |s| s[:type].to_s == cfg.service.catalog_type }   or next
          res = srv[:resources].find { |r| r[:name].to_sym == cfg.name }          or next

          db_res.approved_quota = res[:quota]
          db_res.save! if db_res.changed?
        end
      end

      def put_cluster_data(services)
        services.each do |service|
          service_type = service.type.to_s
          resources.each do |resource|
            resource_name = resource.name.to_sym
            cfg = ResourceManagement::ResourceConfig.all.find { |r| r.name == resource_name and r.service.catalog_type == service_type }
            next unless cfg

            capacity = ResourceManagement::Capacity.where(
              service:  cfg.service.name,
              resource: cfg.name,
            ).first_or_create(
              value:   resource[:capacity],
              comment: resource[:comment],
            )

            capacity.value   = resource[:capacity]
            capacity.comment = resource[:comment]
            capacity.save if capacity.changed?
          end
        end
      end

      private

      def locate_entity_service_resource(entities, entity_id, entity_name, resource_config)
        entity = entities.find { |e| e[:id] == entity_id }
        if entity.nil?
          entity = { id: entity_id, services: [] }
          entities.append(entity)
        end

        service_type = resource_config.service.catalog_type
        service = entity[:services].find { |s| s[:type] == service_type }
        if service.nil?
          service = { type: service_type, resources: [] }
          entity[:services].append(service)
        end

        resource = service[:resources].find { |r| r[:name] == resource_config.name }
        if resource.nil?
          resource = { name: resource_config.name }
          service[:resources].append(resource)
        end

        entity[:name] = entity_name unless entity_name.nil?

        unit_name = resource_config.data_type.unit_name
        resource[:unit]  = unit_name if unit_name != ""

        return entity, service, resource
      end

      def limes_services_to_frontend_services(services)
        ResourceManagement::ServiceConfig.all.select { |srv| services.include?(srv.catalog_type) }.map(&:name).uniq
      end

      ##########################################################################
      # old-style interface

      public

      # Query quotas for the given project from the given service.
      # Returns a hash with resource names as keys. The service argument and
      # the resource names in the result are symbols, with acceptable values
      # defined in ResourceManagement::{ResourceConfig,ServiceConfig}.
      def query_project_quota(domain_id, project_id, service)
        # dispatch into the private implementation methods for each service
        method = "query_project_quota_#{service}".to_sym
        if respond_to?(method, true)
          return send(method, domain_id, project_id)
        else
          return mock_implementation.query_project_quota(domain_id, project_id, service)
        end
      end

      # Query usage values for the given project from the given service.
      # Returns a hash with resource names as keys. The service argument and
      # the resource names in the result are symbols, with acceptable values
      # defined in ResourceManagement::{ResourceConfig,ServiceConfig}.
      def query_project_usage(domain_id, project_id, service)
        # dispatch into the private implementation methods for each service
        method = "query_project_usage_#{service}".to_sym
        if respond_to?(method, true)
          return send(method, domain_id, project_id)
        else
          return mock_implementation.query_project_usage(domain_id, project_id, service)
        end
      end

      # Set quotas for the given project in the given service. `values` must be
      # a hash with resource names as keys. The service argument and resource
      # names are symbols, with acceptable values defined in
      # ResourceManagement::{ResourceConfig,ServiceConfig}.
      def set_project_quota(domain_id, project_id, service, values)
        # dispatch into the private implementation methods for each service
        method = "set_project_quota_#{service}".to_sym
        if respond_to?(method, true)
          return send(method, domain_id, project_id, values)
        else
          # ignore a missing implementation in development mode (where mock data is used)
          raise ServiceLayer::Errors::NotImplemented unless Rails.env.development?
        end
      end

      private

      def mock_implementation
        @mocker ||= ResourceManagement::Driver::Mock.new
      end

      ### OBJECT STORAGE: SWIFT ###################################################################

      def query_project_quota_object_storage(domain_id, project_id)
        metadata = get_swift_account_metadata(domain_id, project_id)
        if metadata.empty?
          # this is the case if account is not accessible or does not exist
          return { capacity: 0 }
        else
          return { capacity: metadata.fetch('X-Account-Meta-Quota-Bytes', -1).to_i }
        end
      end

      def query_project_usage_object_storage(domain_id, project_id)
        metadata = get_swift_account_metadata(domain_id, project_id)
        if metadata.empty?
          # this is the case if account is not accessible or does not exist
          return { capacity: 0 }
        else
          return { capacity: metadata['X-Account-Bytes-Used'].to_i }
        end
      end

      def set_project_quota_object_storage(domain_id, project_id, values)
        return unless values.has_key?(:capacity)

        headers = {
          'x-account-meta-quota-bytes' => values[:capacity],
          # this header brought to you by https://github.com/sapcc/swift-addons
          'x-account-project-domain-id-override' => domain_id,
        }

        with_service_user_connection_for_swift(project_id) do |connection|
          # the post_account request is not yet implemented in Fog (TODO: add it),
          # so let's use request() directly
          begin
            connection.send(:request,
              expects: [200, 204],
              method:  'POST',
              path:    '',
              query:   { format: 'json' },
              headers: headers,
            )
          rescue ::Fog::Storage::OpenStack::NotFound
            # account does not exist yet - if there is a non-zero quota, enable it now
            if values[:capacity] > 0
              connection.send(:request,
                expects: [201],
                method:  'PUT',
                path:    '',
                query:   { format: 'json' },
                headers: headers,
              )
            end
          end
        end
      end

      # The query for quota and usage in Swift use the same request, so this
      # method caches it.
      def get_swift_account_metadata(domain_id, project_id)
        @swift_account_metadata_cache ||= {}
        @swift_account_metadata_cache[project_id] ||= with_service_user_connection_for_swift(project_id) do |connection|
          # the head_account request is not yet implemented in Fog (TODO: add it),
          # so let's use request() directly
          begin
            connection.send(:request,
              # usually 204, but sometimes Swift Kilo inexplicably returns 200
              :expects => [200, 204],
              :method  => 'HEAD',
              :path    => '',
              :query   => { 'format' => 'json' },
            ).headers.to_hash
          rescue ::Fog::Storage::OpenStack::NotFound
            # 404 not found is returned if a project exist but no account was created in swift
            #     that usualy happens if account autocreate is disabled in swift and the user did not create a account
            #     in the object storage plugin of elektra (or somerwhere else with the swift client ;-))
            return {}
          end
        end
      end

      # NOTE: Use like this:
      #
      # with_service_user_connection_for_swift(project_id) do |connection|
      #    ...
      # end
      def with_service_user_connection_for_swift(project_id, options={}, &block)
        # the "service" role usually means "readonly access to everything",
        # but not for Swift; here only the reseller-admin role works; but stuff
        # gets easier again since we only need the reseller-admin role on the
        # service project of the service user

        # establish service user token for service project
        # FIXME: This section is currently more or less a crude hack since the
        # service user refactoring is still in progress across the Dashboard,
        # but we need something functional for our customers *now*.
        #
        # The previous implementation can be found by `git show`ing the commit
        # introducing this comment. The problem with the old implementation is
        # that, while it was nicer, it was relying on the @srv_conn which is
        # usually scoped in the wrong domain and thus cannot locate the service
        # project properly.
        unless @swift_conn and @swift_project_id
          swift_auth_params = {
            openstack_auth_url:       @auth_url,
            openstack_region:         ENV.fetch('SWIFT_RESELLERADMIN_REGION', @region), # region needs to be configurable since we have clouds with different region setup per cluster
            openstack_username:       ENV['MONSOON_OPENSTACK_AUTH_API_USERID'],
            openstack_api_key:        ENV['MONSOON_OPENSTACK_AUTH_API_PASSWORD'],
            openstack_user_domain:    ENV['MONSOON_OPENSTACK_AUTH_API_DOMAIN'],
            openstack_project_name:   ENV['SWIFT_RESELLERADMIN_PROJECT'],
            openstack_project_domain: ENV['SWIFT_RESELLERADMIN_PROJECT_DOMAIN'],
            connection_options:       { ssl_verify_peer: false }, # TODO: necessary?
          }
          @swift_identity = ::Fog::Identity::OpenStack::V3.new(swift_auth_params)
          # find the project ID for the given project name
          auth_projects = @swift_identity.auth_projects.body['projects']
          @swift_project_id = auth_projects.find { |project| project['name'] == ENV['SWIFT_RESELLERADMIN_PROJECT'] }['id']

          @swift_conn = ::Fog::Storage::OpenStack.new(swift_auth_params)

          # extract original storage URL from connection object, and store it
          # since we're going to modify it now
          @swift_conn_path = @swift_conn.instance_variable_get(:@path)
          raise ArgumentError, "spurious storage URL: '#{@swift_conn_path}' does not contain expected service project ID '#{@swift_project_id}'" unless @swift_conn_path.include?(@swift_project_id)
        end

        # adjust the storage URL to point to the desired project (this looks
        # insane, but the admin tasks in the swiftclient also allow to supply a
        # user-defined storage URL, see for example
        # <http://docs.openstack.org/liberty/config-reference/content/object-storage-account-quotas.html>)
        # (TODO: use that reasoning to get a storage_path reader/writer into
        # Fog::Storage::OpenStack)
        storage_path = @swift_conn_path.gsub(@swift_project_id, project_id)
        @swift_conn.instance_variable_set(:@path, storage_path)

        if options[:retrying]
          yield(@swift_conn)
        else
          begin
            yield(@swift_conn)
          rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden
            # if service user does not have the ResellerAdmin role yet, grant
            # it, then retry the request
            role_name = ENV.fetch('SWIFT_RESELLERADMIN_ROLE', 'ResellerAdmin')
            roles = @swift_identity.list_roles(name: role_name).body['roles']
            raise "missing role \"#{role_name}\" in Keystone" if roles.empty?
            @swift_identity.grant_project_user_role(@swift_project_id, @swift_identity.current_user_id, roles.first['id'])

            # clear all relevant instance variables since we need to recreate
            # the service user connection with the new set of roles
            @swift_identity = nil
            @swift_conn = nil
            @swift_conn_path = nil

            # retry, but set options[:retrying] to make sure that we don't try
            # to grant the role again
            with_service_user_connection_for_swift(project_id, options.merge(retrying: true), &block)
          end
        end
      end

      ### BLOCK STORAGE: CINDER ###################################################################

      def fog_block_storage_connection
        # hint: remove caching if it makes problems with token expiration
        @fog_block_storage ||= ::Fog::Volume::OpenStack::V2.new(service_user_auth_params)
      end

      BLOCK_STORAGE_RESOURCE_MAP = {
        'gigabytes' => :capacity,
        'volumes'   => :volumes,
        'snapshots' => :snapshots
      }.freeze

      def set_project_quota_block_storage(_domain_id, project_id, values)
        return unless values.present? && project_id.present?
        quota_values = values.map { |k, v| [BLOCK_STORAGE_RESOURCE_MAP.invert[k], v] }.to_h
        handle_response { fog_block_storage_connection.update_quota(project_id, quota_values) }
      end

      def query_project_quota_block_storage(_domain_id, project_id)
        quotas = handle_response { fog_block_storage_connection.get_quota(project_id).body['quota_set'] }
        quotas.map { |k, v| [BLOCK_STORAGE_RESOURCE_MAP[k], v] }.to_h
      end

      def query_project_usage_block_storage(_domain_id, project_id)
        usage = handle_response { fog_block_storage_connection.get_quota_usage(project_id).body['quota_set'] }
        {
          capacity:   usage['gigabytes']['in_use'],
          volumes:    usage['volumes']['in_use'],
          snapshots:  usage['snapshots']['in_use']
        }
      end

      ### SHARED FILESYSTEM STORAGE: MANILA ###################################################################

      def fog_shared_filesystem_storage_connection
        # hint: remove caching if it makes problems with token expiration
        @fog_shared_filesystem_storage ||= ::Fog::SharedFileSystem::OpenStack.new(service_user_auth_params)
      end

      SHARED_FILESYSTEM_STORAGE_RESOURCE_MAP = {
        'share_networks'     => :share_networks,
        'gigabytes'          => :share_capacity,
        'shares'             => :shares,
        'snapshot_gigabytes' => :snapshot_capacity,
        'snapshots'          => :share_snapshots
      }.freeze

      def set_project_quota_shared_filesystem_storage(_domain_id, project_id, values)
        return unless values.present? && project_id.present?
        quota_values = values.map { |k, v| [SHARED_FILESYSTEM_STORAGE_RESOURCE_MAP.invert[k], v] }.to_h
        handle_response { fog_shared_filesystem_storage_connection.update_quota(project_id, quota_values) }
      end

      def query_project_quota_shared_filesystem_storage(_domain_id, project_id)
        quotas = handle_response { fog_shared_filesystem_storage_connection.get_quota(project_id).body['quota_set'] }
        quotas.map { |k, v| [SHARED_FILESYSTEM_STORAGE_RESOURCE_MAP[k], v] }.to_h
      end

      def query_project_usage_shared_filesystem_storage(_domain_id, project_id)
        # get_limits only works in project scope, not with service user
        # quota_get reports usage with microversion 2.25, we are currently on 2.15
        # TODO: make either of the above work to reduce costs of api-calls
        share_options = { project_id: project_id, all_tenants: 1 }

        shares = handle_response do
          fog_shared_filesystem_storage_connection.list_shares_detail(share_options).body['shares']
        end
        snapshots = handle_response do
          fog_shared_filesystem_storage_connection.list_snapshots_detail(share_options).body['snapshots']
        end
        share_networks = handle_response do
          fog_shared_filesystem_storage_connection.list_share_networks(share_options).body['share_networks']
        end

        share_capacity = 0
        snapshot_capacity = 0

        shares.each do |share|
          share_capacity += share['size'].to_i
        end

        snapshots.each do |snapshot|
          snapshot_capacity += snapshot['share_size'].to_i
        end

        {
          shares:            shares.length,
          share_snapshots:   snapshots.length,
          share_networks:    share_networks.length,
          share_capacity:    share_capacity,
          snapshot_capacity: snapshot_capacity
        }
      end

      ### NETWORKING: NEUTRON ###################################################################

      def fog_network_connection
        # hint: remove caching if it makes problems with token expiration
        @fog_network ||= ::Fog::Network::OpenStack.new(service_user_auth_params)
      end

      NETWORK_RESOURCE_MAP = {
        'network'             => :networks,
        'subnet'              => :subnets,
        'subnetpool'          => :subnet_pools,
        'floatingip'          => :floating_ips,
        'router'              => :routers,
        'port'                => :ports,
        'security_group'      => :security_groups,
        'security_group_rule' => :security_group_rules,
        'rbac_policy'         => :rbac_policies
      }.freeze

      def set_project_quota_networking(_domain_id, project_id, values)
        return unless values.present? && project_id.present?
        quota_values = values.map { |k, v| [NETWORK_RESOURCE_MAP.invert[k], v] }.to_h
        handle_response { fog_network_connection.update_quota(project_id, quota_values) }
      end

      def query_project_quota_networking(_domain_id, project_id)
        quotas = handle_response { fog_network_connection.get_quota(project_id).body['quota'] }

        quotas.map { |k, v| [NETWORK_RESOURCE_MAP[k], v] }.to_h
      end

      def query_project_usage_networking(_domain_id, project_id)
        # TODO: handle via ceilometer - the calls now are very expensive, there are no aggregates

        # filter by project and ask only for id: we just want to count
        net_options = { tenant_id: project_id, fields: 'id' }

        networks              = handle_response { fog_network_connection.list_networks(net_options).body['networks'] }.length
        subnets               = handle_response { fog_network_connection.list_subnets(net_options).body['subnets'] }.length
        subnet_pools          = handle_response { fog_network_connection.list_subnet_pools(net_options).body['subnetpools'] }.length
        floating_ips          = handle_response { fog_network_connection.list_floating_ips(net_options).body['floatingips'] }.length
        routers               = handle_response { fog_network_connection.list_routers(net_options).body['routers'] }.length
        ports                 = handle_response { fog_network_connection.list_ports(net_options).body['ports'] }.length
        security_groups       = handle_response { fog_network_connection.list_security_groups(net_options).body['security_groups'] }.length
        security_group_rules  = handle_response { fog_network_connection.list_security_group_rules(net_options).body['security_group_rules'] }.length
        rbac_policies         = handle_response { fog_network_connection.list_rbac_policies(net_options).body['rbac_policies'] }.length
        loadbalancers         = handle_response { fog_network_connection.list_lbaas_loadbalancers(net_options).body['loadbalancers'] }.length
        listeners             = handle_response { fog_network_connection.list_lbaas_listeners(net_options).body['listeners'] }.length
        pools                 = handle_response { fog_network_connection.list_lbaas_pools(net_options).body['pools'] }.length
        healthmonitors        = handle_response { fog_network_connection.list_lbaas_healthmonitors(net_options).body['healthmonitors'] }.length
        l7policies            = handle_response { fog_network_connection.list_lbaas_l7policies(net_options).body['l7policies'] }.length

        {
          networks:             networks,
          subnets:              subnets,
          subnet_pools:         subnet_pools,
          floating_ips:         floating_ips,
          routers:              routers,
          ports:                ports,
          security_groups:      security_groups,
          security_group_rules: security_group_rules,
          rbac_policies:        rbac_policies,
          loadbalancers:        loadbalancers,
          listeners:            listeners,
          pools:                pools,
          healthmonitors:       healthmonitors,
          l7policies:           l7policies
        }
      end

      ### LOADBALANCING: NEUTRON ###################################################################

      LBAAS_RESOURCE_MAP = {
        'loadbalancer'        => :loadbalancers,
        'listener'            => :listeners,
        'pool'                => :pools,
        'healthmonitor'       => :healthmonitors,
        'l7policy'            => :l7policies
      }.freeze

      def set_project_quota_loadbalancing(_domain_id, project_id, values)
        return unless values.present? && project_id.present?
        quota_values = values.map { |k, v| [LBAAS_RESOURCE_MAP.invert[k], v] }.to_h
        handle_response { fog_network_connection.update_quota(project_id, quota_values) }
      end

      def query_project_quota_loadbalancing(_domain_id, project_id)
        quotas = handle_response { fog_network_connection.get_quota(project_id).body['quota'] }

        quotas.map { |k, v| [LBAAS_RESOURCE_MAP[k], v] }.to_h
      end

      def query_project_usage_loadbalancing(_domain_id, project_id)
        # TODO: handle via ceilometer - the calls now are very expensive, there are no aggregates

        # filter by project and ask only for id: we just want to count
        net_options = { tenant_id: project_id, fields: 'id' }

        loadbalancers         = handle_response { fog_network_connection.list_lbaas_loadbalancers(net_options).body['loadbalancers'] }.length
        listeners             = handle_response { fog_network_connection.list_lbaas_listeners(net_options).body['listeners'] }.length
        pools                 = handle_response { fog_network_connection.list_lbaas_pools(net_options).body['pools'] }.length
        healthmonitors        = handle_response { fog_network_connection.list_lbaas_healthmonitors(net_options).body['healthmonitors'] }.length
        l7policies            = handle_response { fog_network_connection.list_lbaas_l7policies(net_options).body['l7policies'] }.length

        {
          loadbalancers:        loadbalancers,
          listeners:            listeners,
          pools:                pools,
          healthmonitors:       healthmonitors,
          l7policies:           l7policies
        }
      end

      ### COMPUTE: NOVA ###################################################################

      def fog_compute_connection
        # hint: remove caching if it makes problems with token expiration
        @fog_compute ||= ::Fog::Compute::OpenStack.new(service_user_auth_params)
      end

      COMPUTE_RESOURCE_MAP = {
        # 'key_pairs'                   => :key_pairs,
        # 'metadata_items'              => :metadata_items,
        # 'server_groups'               => :server_groups,
        # 'server_group_members'        => :server_group_members,
        # 'injected_files'              => :injected_files,
        # 'injected_file_content_bytes' => :injected_file_content_bytes,
        # 'injected_file_path_bytes'    => :injected_file_path_bytes,
        # 'fixed_ips'                   => :fixed_ips,
        'cores'                       => :cores,
        'instances'                   => :instances,
        'ram'                         => :ram
      }.freeze

      def set_project_quota_compute(_domain_id, project_id, values)
        return unless values.present? && project_id.present?
        quota_values = values.map { |k, v| [COMPUTE_RESOURCE_MAP.invert[k], v] }.to_h
        handle_response { fog_compute_connection.update_quota(project_id, quota_values) }
      end

      def query_project_quota_compute(_domain_id, project_id)
        quotas = handle_response { fog_compute_connection.get_quota(project_id).body['quota_set'] }
        quotas.map { |k, v| [COMPUTE_RESOURCE_MAP[k], v] }.to_h
      end

      def query_project_usage_compute(_domain_id, project_id)
        limits = handle_response { fog_compute_connection.get_limits(tenant_id: project_id).body['limits']['absolute'] }
        {
          cores:     limits['totalCoresUsed'],
          instances: limits['totalInstancesUsed'],
          ram:       limits['totalRAMUsed']
        }
      end

      ### DNS: DESIGNATE ###################################################################

      def fog_dns_connection
        # hint: remove caching if it makes problems with token expiration
        @fog_dns ||= ::Fog::DNS::OpenStack::V2.new(service_user_auth_params)
      end

      DNS_RESOURCE_MAP = {
        'zones'           => :zones,
        'zone_recordsets' => :recordsets,
        'zone_records'    => :records
      }.freeze

      def set_project_quota_dns(_domain_id, project_id, values)
        return unless values.present? && project_id.present?
        quota_values = values.map { |k, v| [DNS_RESOURCE_MAP.invert[k], v] }.to_h
        # activating admin action
        quota_values[:all_projects] = true
        # if we change quota for recordsets, we automatically adjust records
        if zone_recordsets = quota_values['zone_recordsets']
          quota_values['zone_records'] = zone_recordsets * 20 # 20 is the default records_per_recordset quota
        end
        handle_response { fog_dns_connection.update_quota(project_id, quota_values) }
      end

      def query_project_quota_dns(_domain_id, project_id)
        quotas = handle_response { fog_dns_connection.get_quota(project_id).body }
        quotas.map { |k, v| [DNS_RESOURCE_MAP[k], v] }.to_h
      end

      def query_project_usage_dns(_domain_id, project_id)
        zones_response = handle_response { fog_dns_connection.list_zones(project_id: project_id) }
        zones_count = zones_response.body['metadata']['total_count']

        recordset_counts = [0]

        # max count of recordsets per zone per project
        # FIXME: very expensive - check the previous version for a simpler solution or use ceilometer
        # need to iterate over zones, as quota is per zone, total project usage (which can be queried) would not help
        zones_response.body['zones'].each do |zone|
          total_count = fog_dns_connection.list_recordsets(
            zone_id: zone['id'],
            project_id: project_id,
            # don't want the data, just the meta for the count
            limit: 1
          ).body['metadata']['total_count']
          recordset_counts << total_count.to_i
        end

        recordsets = recordset_counts.max
        # IDEA: do more with the recordset_counts than grabbing the max value

        {
          zones:      zones_count,
          recordsets: recordsets
        }
      end
    end
  end
end
