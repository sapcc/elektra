module Core
  module ServiceLayer
    module FogDriver
      module ClientHelper
        def auth_params
          result = {
            provider: 'openstack',
            openstack_auth_token: @token,
            openstack_auth_url: @auth_url,
            openstack_region: @region
          }
    
          result[:openstack_domain_id]  = @domain_id if @domain_id
          result[:openstack_project_id] = @project_id if @project_id
    
          # remove this shit after the certificates for endpoints are configured correctly! 
          result[:connection_options]= { ssl_verify_peer: false, debug: Rails.application.config.debug_api_calls }
    
          result  
        end
      end
    end
  end
end