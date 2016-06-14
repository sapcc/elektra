module Core
  module ServiceLayer
    module FogDriver
      module ClientHelper
        def auth_params
          result = common_params

          result[:openstack_auth_token] = @token
          result[:openstack_domain_id] = @domain_id if @domain_id
          result[:openstack_project_id] = @project_id if @project_id
          if Rails.env.development? || Rails.env.test?
            result[:openstack_endpoint_type] = "publicURL"
          else
            result[:openstack_endpoint_type] = "internalURL"
          end
          result
        end

        def service_user_auth_params
          result = common_params

          result[:openstack_username] = Rails.configuration.service_user_id
          result[:openstack_api_key] = Rails.configuration.service_user_password
          result[:openstack_user_domain] = Rails.configuration.service_user_domain_name
          result[:openstack_domain_name] = Rails.configuration.default_domain

          result
        end

        private

        def common_params
          result = {
              openstack_auth_url: @auth_url,
              openstack_region: @region
          }

          result[:connection_options] = {
              # remove this shit after the certificates for endpoints are configured correctly!
              ssl_verify_peer: false,
              debug_request: Rails.configuration.debug_api_calls,
              debug_response: Rails.configuration.debug_api_calls
              # please don't add non-supported Excon connection keys here (f.i. :debug)!
          }

          result
        end
      end
    end
  end
end
