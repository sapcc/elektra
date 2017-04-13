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

        query = Excon::Utils.query_string(query:options).sub!(/^\?/, '')

        if project_id.nil?
          # need to check nil query because nil is not working as optional parameter in misty
          handle_response do
            if query.nil?
              @misty.resources.get_projects(domain_id).body['projects']
            else
              @misty.resources.get_projects(domain_id,query).body['projects']
            end
          end
        else
          handle_response do
            if query.nil?
              @misty.resources.get_project(domain_id,project_id).body['project']
            else
              @misty.resources.get_project(domain_id,project_id,query).body['project']
            end
          end
        end
      end

    end
  end
end