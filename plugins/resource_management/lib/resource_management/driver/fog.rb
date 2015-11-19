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

      # List all projects that exist, in the form { "domain_id": "xxx", "id": "xxx" }.
      def enumerate_projects
        result = []

        @srv_conn.list_domains.body['domains'].each do |domain|
          @srv_conn.list_projects(domain_id: domain['id']).body['projects'].each do |project|
            result.append({ domain_id: domain['id'], id: project['id'] })
          end
        end

        return result
      end

      def get_project_usage_swift(domain_id, project_id)
        # TODO: The following fails because the "service" role is not enough
        # for Swift.  Therefore, this mock implementation reports a usage of 1
        # GiB and quota of 2 GiB for every project.
        return { capacity: 1 << 30, quota: 2 << 30 }

        connection = get_service_user_connection(::Fog::Storage::OpenStack, domain_id, project_id)

        # the head_account request is not yet implemented in Fog (TODO: add it),
        # so we use request() directly
        response = connection.request(
          :expects => 204,
          :method  => 'HEAD',
          :path    => '',
          :query   => { 'format' => 'json' },
        )
        raise "implementation not finished"
      end

      private

      def get_service_user_connection(fog_class, domain_id, project_id)
        # establish service user connection to selected domain/project (this is
        # a bit ugly since MonsoonOpenstackAuth does not want to give us the
        # password back, so we have to resort to ENV there)
        auth_params = {
          provider:                    'openstack',
          openstack_auth_url:          @auth_url,
          openstack_region:            @region,
          openstack_username:          ENV['MONSOON_OPENSTACK_AUTH_API_USERID'],
          openstack_user_domain:       ENV['MONSOON_OPENSTACK_AUTH_API_DOMAIN'],
          openstack_api_key:           ENV['MONSOON_OPENSTACK_AUTH_API_PASSWORD'],
          openstack_project_domain_id: domain_id,
          openstack_project_id:        project_id,
        }

        begin
          connection = fog_class.new(auth_params)
        rescue Excon::Errors::Unauthorized => e
          if e.response.body =~ /has no access to the requested project scope/
            # this is the first time that the dashboard user tries to access
            # this project -> grant service user role in this project
            roles = @srv_conn.list_roles(name: 'service').body['roles']
            raise "missing role \"service\" in Keystone" if roles.empty?
            @srv_conn.grant_project_user_role(project_id, @srv_conn.current_user_id, roles.first['id'])
          else
            # re-raise unknown errors
            raise e
          end
        end

        # try again if we had to grant the service role in the rescue block above
        return connection || fog_class.new(auth_params)
      end

    end
  end
end
