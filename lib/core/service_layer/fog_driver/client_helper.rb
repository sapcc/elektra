module Core
  module ServiceLayer
    module FogDriver
      module ClientHelper
        def auth_params
          result = common_params

          result[:openstack_auth_token] = @token
          result[:openstack_domain_id] = @domain_id if @domain_id
          result[:openstack_project_id] = @project_id if @project_id

          result
        end

        def service_user_auth_params
          result = common_params

          result[:openstack_username]       = Rails.configuration.service_user_id
          result[:openstack_api_key]        = Rails.configuration.service_user_password
          result[:openstack_user_domain]    = Rails.configuration.service_user_domain_name
          result[:openstack_project_name]   = Rails.configuration.cloud_admin_project
          result[:openstack_project_domain] = Rails.configuration.cloud_admin_domain

          result
        end

        private

        def common_params
          result = {
            openstack_auth_url: @auth_url,
            openstack_region: @region
          }

          result[:openstack_endpoint_type] = if Rails.env.development? || Rails.env.test?
                                               'publicURL'
                                             else
                                               'internalURL'
                                             end

          result[:connection_options] = {
            debug_request: Rails.configuration.debug_api_calls,
            debug_response: Rails.configuration.debug_api_calls,
            ssl_verify_peer: Rails.configuration.ssl_verify_peer
            # please don't add non-supported Excon connection keys here (f.i. :debug)!
          }

          if @connection_options and @connection_options.is_a?(Hash)
            if result[:connection_options]
              result[:connection_options].merge!(@connection_options)
            else
              result[:connection_options] = @connection_options
            end
          end

          result
        end
      end
    end
  end
end
