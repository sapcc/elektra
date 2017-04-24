module Core
  module ServiceLayer
    module MistyDriver
      module ClientHelper

        def misty_auth_params
          return {
            :url            => @auth_url,
            :token          => @token,
            :domain_id      => @domain_id,
            :project_id     => @project_id,
            :user_domain_id => @domain_id,
          }.reject { |_,value| value.nil? }
        end

      end
    end
  end
end
