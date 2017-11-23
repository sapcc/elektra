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
          region_id:       Rails.configuration.default_region,
          ssl_verify_mode: Rails.configuration.ssl_verify_peer,
          interface:       ENV['DEFAULT_SERVICE_INTERFACE'] || 'internal',
          log_level:       Logger::INFO,
          keep_alive_timeout: 5,
          #headers: { "Accept-Encoding" => "" },

          # compute: {:version => '2.9'}, ...waiting for backend support

          # needed because of wrong urls in service catalog.
          # The identity url contains a /v3. This leads to a wrong url in misty!
          identity: { base_path: '/' },
          resources: { interface: 'public' },
          database: { interface: 'public' },
          metrics: { interface: 'public' },
          masterdata:  { interface: 'public' },
          shared_file_systems: { service_name: 'sharev2' }
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
        ::Misty::Cloud.new(
          {
            auth: {
              context: {
                catalog: current_user.context['catalog'],
                expires: current_user.context['expires_at'],
                token: current_user.token
              }
            },
          }.merge(default_client_params).merge(SERVICE_OPTIONS)
        )
      end

      def self.create_service_user_api_client(scope_domain)
        misty_params = {
          auth: {
            url:            ::Core.keystone_auth_endpoint,
            user:           Rails.application.config.service_user_id,
            user_domain:    Rails.application.config.service_user_domain_name,
            password:       Rails.application.config.service_user_password,
            domain:         scope_domain
          }
        }.merge(default_client_params)

        begin
          Misty::Cloud.new(misty_params)
        rescue Misty::Auth::AuthenticationError => _e
          unless misty_params[:auth][:domain_id]
            misty_params[:auth].delete(:domain)
            misty_params[:auth][:domain_id] = scope_domain
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
        Misty::Cloud.new(
          {
            auth: {
              url:            ::Core.keystone_auth_endpoint,
              user:           Rails.application.config.service_user_id,
              user_domain:    Rails.application.config.service_user_domain_name,
              password:       Rails.application.config.service_user_password,
              project:        Rails.configuration.cloud_admin_project,
              project_domain: Rails.configuration.cloud_admin_domain
            }
          }.merge(default_client_params)
        )
      end
    end
  end
end
