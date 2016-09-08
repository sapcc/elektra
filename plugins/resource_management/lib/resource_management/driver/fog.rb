require 'fog/storage/openstack'

module ResourceManagement
  module Driver
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper

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
          # this is the case if account is not accesible or not created
          return { capacity: nil }
        else
          return { capacity: metadata.fetch('X-Account-Meta-Quota-Bytes', -1).to_i }
        end
      end

      def query_project_usage_object_storage(domain_id, project_id)
        metadata = get_swift_account_metadata(domain_id, project_id)
        if metadata.empty?
          # this is the case if account is not accesible or not created
          return { capacity: nil }
        else
          return { capacity: metadata['X-Account-Bytes-Used'].to_i }
        end
      end

      def set_project_quota_object_storage(domain_id, project_id, values)
        return unless values.has_key?(:capacity)

        with_service_user_connection_for_swift(project_id) do |connection|
          # the post_account request is not yet implemented in Fog (TODO: add it),
          # so let's use request() directly
          begin
            connection.send(:request,
              expects: [200, 204],
              method:  'POST',
              path:    '',
              query:   { format: 'json' },
              headers: { 'x-account-meta-quota-bytes' => values[:capacity] },
            )
          rescue ::Fog::Storage::OpenStack::NotFound
            return
          end
          return
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

      ### NETWORKING: NEUTRON ###################################################################

      def fog_network_connection
        # hint: remove caching if it makes problems with token expiration
        @fog_network ||= ::Fog::Network::OpenStack.new(service_user_auth_params)
      end

      NETWORK_RESOURCE_MAP = {
        'network'             => :networks,
        'subnet'              => :subnets,
        # 'subnetpool'          => :subnet_pools,
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
        # TODO: do we even need to handle subnet_pools quota-wise or will this stay cloud-admin only?
        # TODO: if yes: needs implementation in fog
        # subnet_pools          = handle_response { fog_network_connection.list_subnet_pools(net_options).body['subnet_pools'] }.length
        floating_ips          = handle_response { fog_network_connection.list_floating_ips(net_options).body['floatingips'] }.length
        routers               = handle_response { fog_network_connection.list_routers(net_options).body['routers'] }.length
        ports                 = handle_response { fog_network_connection.list_ports(net_options).body['ports'] }.length
        security_groups       = handle_response { fog_network_connection.list_security_groups(net_options).body['security_groups'] }.length
        security_group_rules  = handle_response { fog_network_connection.list_security_group_rules(net_options).body['security_group_rules'] }.length
        rbac_policies         = handle_response { fog_network_connection.list_rbac_policies(net_options).body['rbac_policies'] }.length

        {
          networks:             networks,
          subnets:              subnets,
          # subnet_pools:        subnet_pools,
          floating_ips:         floating_ips,
          routers:              routers,
          ports:                ports,
          security_groups:      security_groups,
          security_group_rules: security_group_rules,
          rbac_policies:        rbac_policies
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
        'zone_recordsets' => :recordsets
      }.freeze

      def set_project_quota_dns(_domain_id, project_id, values)
        return unless values.present? && project_id.present?
        quota_values = values.map { |k, v| [DNS_RESOURCE_MAP.invert[k], v] }.to_h
        # activating admin action
        quota_values[:all_projects] = true
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
        zones_response.body['zones'].each do |zone|
          total_count = fog_dns_connection.list_recordsets(
            zone_id: zone['id'],
            project_id: project_id,
            # don't want the data, just the meta for the count
            limit: 1
          ).body['metadata']['total_count']
          recordset_counts << total_count.to_i
        end

        # IDEA: do more with the recordset_counts than grabbing the max value

        {
          zones:      zones_count,
          recordsets: recordset_counts.max
        }
      end
    end
  end
end
