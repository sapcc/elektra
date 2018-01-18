# frozen_string_literal: true

module Core
  module Api
    # this class manages the api clients for service user.
    # The client is created for each domain (organization) and
    # stored in class variable.
    class ClientManager
      @service_user_api_client_mutex = Mutex.new
      @cloud_admin_api_client_mutex = Mutex.new

      def self.default_client_params
        {
          region: Rails.configuration.default_region,
          interface: ENV['DEFAULT_SERVICE_INTERFACE'] || 'internal',
          debug: Rails.env.development?,
          client: {
            open_timeout: 10,
            read_timeout: 30,
            verify_ssl: Rails.configuration.ssl_verify_peer,
            keep_alive_timeout: 30
          }
        }
      end

      def self.service_user_api_client(scope_domain)
        return nil if scope_domain.nil?

        @service_user_api_client_mutex.synchronize do
          @service_user_api_clients ||= {}

          # the service user clients are created per domain (organization)
          # and are stored in class variable
          unless @service_user_api_clients[scope_domain]
            @service_user_api_clients[scope_domain] =
              create_service_user_api_client(scope_domain)
          end
        end
        @service_user_api_clients[scope_domain]
      end

      def self.cloud_admin_api_client
        unless @cloud_admin_api_client
          @cloud_admin_api_client_mutex.synchronize do
            @cloud_admin_api_client = create_cloud_admin_api_client
          end
        end
        @cloud_admin_api_client
      end

      def self.user_api_client(current_user)
        create_user_api_client(current_user)
      end

      def self.create_user_api_client(current_user)
        ::Elektron.client(
          {
            token_context: current_user.context,
            token: current_user.token
          },
          default_client_params
        )
      end

      def self.create_service_user_api_client(scope_domain)
        auth_config = {
          url: ::Core.keystone_auth_endpoint,
          user_name: Rails.application.config.service_user_id,
          user_domain_name: Rails.application.config.service_user_domain_name,
          password: Rails.application.config.service_user_password,
          scope_domain_name: scope_domain
        }
        begin
          ::Elektron.client(auth_config, default_client_params)
          # Misty::Cloud.new(misty_params)
        rescue ::Elektron::Errors::ApiResponse => _e
          unless auth_config[:scope_domain_id]
            auth_config.delete(:scope_domain_name)
            auth_config[:scope_domain_id] = scope_domain
            retry
          end

          raise ::Core::Error::ServiceUserNotAuthenticated,
                <<~ERROR
                  Could not authenticate service user.
                  domain: #{scope_domain}
                ERROR
        end
      end

      def self.create_cloud_admin_api_client
        ::Elektron.client(
          {
            url: ::Core.keystone_auth_endpoint,
            user_name: Rails.application.config.service_user_id,
            user_domain_name: Rails.application.config.service_user_domain_name,
            password: Rails.application.config.service_user_password,
            scope_project_name: Rails.configuration.cloud_admin_project,
            scope_project_domain_name: Rails.configuration.cloud_admin_domain
          },
          default_client_params
        )
      end
    end
  end
end
