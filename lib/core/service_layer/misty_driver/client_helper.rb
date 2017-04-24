require 'misty/openstack/limes'

module Core
  module ServiceLayer
    module MistyDriver
      module ClientHelper

        def misty_auth_params
          return {
            url:            @auth_url,
            token:          @token,
            domain_id:      @domain_id,
            project_id:     @project_id,
            user_domain_id: @domain_id,
          }.reject { |_,value| value.nil? }
        end

        def misty
          @misty_cloud ||= ::Misty::Cloud.new(
            auth:            misty_auth_params,
            region_id:       @region,
            ssl_verify_mode: Rails.configuration.ssl_verify_peer,
            http_proxy:      ENV['http_proxy'],
          )
        end

      end
    end
  end
end
