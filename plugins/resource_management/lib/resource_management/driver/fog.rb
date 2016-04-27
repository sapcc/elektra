require 'fog/openstack/storage'

module ResourceManagement
  module Driver
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper

      def initialize(params)        
        super(params)
        # get existing service user connection (we need this to enumerate all
        # existing domains and projects, and to authorize the service user's
        # access to new domains and projects where necessary)

        # set service_user_token given by params (see app/services/service_layer/resource_management_service.rb)
        @service_user_token = params[:service_user_token]
        
        # create service_user_connection
        @srv_conn = self.class.service_user_connection(@service_user_token,auth_params)
      end  
      
      def self.service_user_connection(service_user_token,auth_params)
        params = auth_params.select{|k,v| [:provider, :openstack_auth_url, :openstack_region, :connection_options].include?(k)}.merge(openstack_auth_token: service_user_token)
        @service_user_connection ||= ::Fog::Identity::OpenStack::V3.new(params)
      end    

      # List all domains that exist, as a hash of { id => name }.
      def enumerate_domains
        result = {}
        @srv_conn.list_domains.body['domains'].each do |domain|
          result[ domain['id'] ] = domain['name']
        end
        return result
      end

      # List all project IDs that exist in the given domain.
      def enumerate_project_ids(domain_id)
        # extrawurst for legacy monsoon2: consider only relevant projects
        # 1. skip legacy organizations (= Keystone projects with ID starting with "o-")
        # 2. skip legacy projects that are not Swift-enabled (by checking for role assignments to "swiftoperator")
        # This radically reduces the syncing time (since only about half of the
        # Keystone projects are legacy projects, and only a small fraction of
        # those actually use Swift).
        domain_name = @srv_conn.get_domain(domain_id).body.fetch('domain', {}).fetch('name', '')
        if domain_name == 'monsoon2'
          # resolve role name into ID
          role_name = 'swiftoperator'
          role_id   = @srv_conn.list_roles(name: role_name).body['roles'].first['id']
          Rails.logger.warn "ResourceManagement > sync_domain(#{domain_id}): will only consider projects with #{role_name} role assignment"

          # iterate over role assignments
          result = []
          @srv_conn.list_role_assignments("role.id" => role_id).body['role_assignments'].each do |assignment|
            if project_id = assignment['scope'].fetch('project', {})['id']
              # IDs of actual projects start with "p-"; this filters legacy organizations
              result << project_id if project_id.start_with?('p-')
            end
          end
          return result.uniq
        end

        # the usual case: list all projects
        return @srv_conn.list_projects(domain_id: domain_id).body['projects'].map { |project| project['id'] }
      end

      def get_project_name(domain_id, project_id)
        @srv_conn.get_project(project_id).body.fetch('project', {}).fetch('name', nil)
      end

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
            connection.request(
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
            connection.request(
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
          @swift_domain_id = @swift_identity.list_domains(name: ENV['SWIFT_RESELLERADMIN_PROJECT_DOMAIN']).body['domains'].first['id']
          @swift_project_id = @swift_identity.list_projects(name: ENV['SWIFT_RESELLERADMIN_PROJECT'], domain_id: @swift_domain_id).body['projects'].first['id']

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


    end
  end
end
