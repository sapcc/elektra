require 'fog/openstack/storage'

module ResourceManagement
  module Driver
    class Fog < Interface
      include DomainModelServiceLayer::FogDriver::ClientHelper

      def initialize(params)
        super(params)
        # get existing service user connection (we need this to enumerate all
        # existing domains and projects, and to authorize the service user's
        # access to new domains and projects where necessary)
        @srv_conn = MonsoonOpenstackAuth.api_client(@region).connection_driver.connection
      end

      # List all domain IDs that exist.
      def enumerate_domains
        @srv_conn.list_domains.body['domains'].map { |domain| domain['id'] }
      end

      # List all project IDs that exist in the given domain.
      def enumerate_projects(domain_id)
        @srv_conn.list_projects(domain_id: domain_id).body['projects'].map { |domain| domain['id'] }
      end

      # Query quotas for the given project from the given service.
      # Returns a hash with resource names as keys. The service argument and
      # the resource names in the result are symbols, with acceptable values
      # defined in ResourceManagement::Resource::KNOWN_RESOURCES.
      def query_project_quota(domain_id, project_id, service)
        # dispatch into the private implementation methods for each service
        return send("query_project_quota_#{service}", domain_id, project_id)
      end

      # Query usage values for the given project from the given service.
      # Returns a hash with resource names as keys. The service argument and
      # the resource names in the result are symbols, with acceptable values
      # defined in ResourceManagement::Resource::KNOWN_RESOURCES.
      def query_project_usage(domain_id, project_id, service)
        # dispatch into the private implementation methods for each service
        return send("query_project_usage_#{service}", domain_id, project_id)
      end

      private

      def query_project_quota_compute(domain_id, project_id)
        # TODO: mock implementation
        return {
          cores:     rand(0..100),
          instances: rand(0..100),
          ram:       rand(0..100),
        }
      end

      def query_project_usage_compute(domain_id, project_id)
        # TODO: mock implementation
        return {
          cores:     rand(0..100),
          instances: rand(0..100),
          ram:       rand(0..100),
        }
      end

      def query_project_quota_network(domain_id, project_id)
        # TODO: mock implementation
        return {
          floating_ips:    rand(0..100),
          networks:        rand(0..100),
          ports:           rand(0..100),
          routers:         rand(0..100),
          security_groups: rand(0..100),
          subnets:         rand(0..100),
        }
      end

      def query_project_usage_network(domain_id, project_id)
        # TODO: mock implementation
        return {
          floating_ips:    rand(0..100),
          networks:        rand(0..100),
          ports:           rand(0..100),
          routers:         rand(0..100),
          security_groups: rand(0..100),
          subnets:         rand(0..100),
        }
      end

      def query_project_quota_block_storage(domain_id, project_id)
        # TODO: mock implementation
        return {
          capacity:  rand(0..(100 << 30)), # max 100 GiB
          snapshots: rand(0..100),
          volumes:   rand(0..100),
        }
      end

      def query_project_usage_block_storage(domain_id, project_id)
        # TODO: mock implementation
        return {
          capacity:  rand(0..(100 << 30)), # max 100 GiB
          snapshots: rand(0..100),
          volumes:   rand(0..100),
        }
      end

      def query_project_quota_object_storage(domain_id, project_id)
        puts "QUOTA FOR #{domain_id} -> #{project_id}"
        # the "service" role usually means "readonly access to everything",
        # but not for Swift; here only the reseller-admin role works
        with_service_user_connection(::Fog::Storage::OpenStack, domain_id, project_id, role_name: 'ResellerAdmin') do |connection|
          # the head_account request is not yet implemented in Fog (TODO: add it),
          # so let's use request() directly
          response = connection.request(
            :expects => [200, 204], # usually 204, but sometimes Swift Kilo inexplicably returns 200
            :method  => 'HEAD',
            :path    => '',
            :query   => { 'format' => 'json' },
          )

          # if the field is missing, no quota is set, so -1 will be returned
          return { capacity: response.headers.fetch('X-Account-Meta-Quota-Bytes', -1).to_i }
        end
      end

      def query_project_usage_object_storage(domain_id, project_id)
        puts "USAGE FOR #{domain_id} -> #{project_id}"
        # the "service" role usually means "readonly access to everything",
        # but not for Swift; here only the reseller-admin role works
        with_service_user_connection(::Fog::Storage::OpenStack, domain_id, project_id, role_name: 'ResellerAdmin') do |connection|
          # the head_account request is not yet implemented in Fog (TODO: add it),
          # so let's use request() directly
          response = connection.request(
            :expects => [200, 204], # usually 204, but sometimes Swift Kilo inexplicably returns 200
            :method  => 'HEAD',
            :path    => '',
            :query   => { 'format' => 'json' },
          )

          return { capacity: response.headers['X-Account-Bytes-Used'].to_i }
        end
      end

      def with_service_user_connection(fog_class, domain_id, project_id, options={}, &block)
        # establish service user connection to selected domain/project (this is
        # a bit ugly since MonsoonOpenstackAuth does not want to give us the
        # password back, so we have to resort to ENV there)
        auth_params = {
          openstack_auth_url:          @auth_url,
          openstack_region:            @region,
          openstack_username:          ENV['MONSOON_OPENSTACK_AUTH_API_USERID'],
          openstack_user_domain:       ENV['MONSOON_OPENSTACK_AUTH_API_DOMAIN'],
          openstack_api_key:           ENV['MONSOON_OPENSTACK_AUTH_API_PASSWORD'],
          openstack_project_domain_id: domain_id,
          openstack_project_id:        project_id,
        }

        return yield(fog_class.new(auth_params))
      rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden
        # dashboard user may not have access to this project yet -> grant
        # service user role in this project
        service_role_name = options[:role_name] || 'service'
        roles = @srv_conn.list_roles(name: service_role_name).body['roles']
        raise "missing role \"service\" in Keystone" if roles.empty?
        @srv_conn.grant_project_user_role(project_id, @srv_conn.current_user_id, roles.first['id'])

        # try again after granting the service role
        return yield(fog_class.new(auth_params))
      end

    end
  end
end
