require 'misty/openstack/limes'

module ResourceManagement
  module Driver
    class Misty < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper

      def initialize(params_or_driver)
          super(params_or_driver)
          @misty = ::Misty::Cloud.new(:auth => misty_auth_params, :region_id => @region, :log_level => 2, :ssl_verify_mode => false, :http_proxy => ENV['http_proxy'])
      end

      def get_project_data(domain_id, project_id=nil, options={})
        
        # need to check nil query because nil is not working as optional parameter in misty
        query = Excon::Utils.query_string(query:options).sub(/^\?/, '')

        handle_response do
          if project_id.nil?
            if query.empty?
              @misty.resources.get_projects(domain_id).body['projects']
            else
              @misty.resources.get_projects(domain_id,query).body['projects']
            end
          else
            if query.empty?
              @misty.resources.get_project(domain_id,project_id).body['project']
            else
              @misty.resources.get_project(domain_id,project_id,query).body['project']
            end
          end
        end
        
      end

      def get_domain_data(domain_id=nil, options={})
        
        # need to check nil query because nil is not working as optional parameter in misty
        query = Excon::Utils.query_string(query:options).sub(/^\?/, '')
        handle_response do
          if domain_id.nil?
            if query.empty?
              @misty.resources.get_domains.body['domains']
            else
              @misty.resources.get_domains(query).body['domains']
            end
          else
            if query.empty?
              @misty.resources.get_domain(domain_id).body['domain']
            else
              @misty.resources.get_domain(domain_id,query).body['domain']
            end
          end
        end
      end

      def get_cluster_data(options={})
        
        # need to check nil query because nil is not working as optional parameter in misty
        query = Excon::Utils.query_string(query:options).sub(/^\?/, '')
        handle_response do
          if query.empty?
            @misty.resources.get_current_cluster.body['cluster']
          else
            @misty.resources.get_current_cluster(query).body['cluster']
          end
        end
        
      end

      def put_project_data(domain_id, project_id, services)
        handle_response do
          @misty.resources.set_quota_for_project(domain_id,project_id, :project => {:services => services})
        end
        # FIXME: related to @services_with_error, can be removed when we remove the old code
        return []
      end
      
      def put_domain_data(domain_id, services)
      end
      
      def put_cluster_data(services)
      end

    end
  end
end