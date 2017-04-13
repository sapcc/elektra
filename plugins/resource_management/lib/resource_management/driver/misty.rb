require 'misty/openstack/limes'

module ResourceManagement
  module Driver
    class Misty < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper

      def initialize(params_or_driver)
          super(params_or_driver)
          @misty = ::Misty::Cloud.new(:auth => misty_auth_params, :region_id => @region, :log_level => 2, :ssl_verify_mode => false)
      end

      def get_project_data(domain_id, project_id=nil, options={})
        if project_id.nil?
          handle_response do
            @misty.resources.get_projects(domain_id).body['projects']
          end
        else
          handle_response do
            @misty.resources.get_project(domain_id,project_id).body['project']
          end
        end
      end

    end
  end
end