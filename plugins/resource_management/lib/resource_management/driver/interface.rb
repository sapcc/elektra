module ResourceManagement
  module Driver
    class Interface < Core::ServiceLayer::Driver::Base

      ##########################################################################
      # read operations

      # Get resource data for the given project (or all projects if the project
      # ID is nil). options[:services] can be set to a list of services to
      # restrict the query to these.  options[:resources] can be set to a list
      # of resources in the same way.
      #
      # The data is returned in the format specified by the Limes API request
      # GET /v1/domains/:domain_id/projects(/:project_id), but with the
      # outermost JSON object stripped.
      def get_project_data(domain_id, project_id=nil, options={})
        raise ServiceLayer::Errors::NotImplemented
      end

      # Get resource data for the given domain (or all domains in this cluster
      # if the domain ID is nil). All comments for get_project_data apply
      # respectively. This call mirrors the Limes API request
      # GET /v1/domains(/:domain_id).
      def get_domain_data(domain_id=nil, options={})
        raise ServiceLayer::Errors::NotImplemented
      end

      # Get resource data for the current cluster. All comments for
      # get_project_data apply respectively. This call mirrors the Limes API
      # request GET /v1/clusters/current.
      def get_cluster_data(options={})
        raise ServiceLayer::Errors::NotImplemented
      end

      ##########################################################################
      # write operations

      # Set quotas for the given project. `services` is the request body
      # expected by Limes, minus the outermost two JSON objects (i.e. starting
      # at the `services` level).
      #
      # The legacy (non-Limes) implementation will return an array of service
      # names, indicating those backend services where the quota update failed.
      # The Limes-powered implementation shall return an empty array instead.
      def put_project_data(domain_id, project_id, services)
        raise ServiceLayer::Errors::NotImplemented
      end

      # Set quotas for the given domain. `services` is the request body
      # expected by Limes, minus the outermost two JSON objects (i.e. starting
      # at the `services` level).
      def put_domain_data(domain_id, services)
        raise ServiceLayer::Errors::NotImplemented
      end

      # Set capacities for the current cluster. `services` is the request body
      # expected by Limes, minus the outermost two JSON objects (i.e. starting
      # at the `services` level).
      def put_cluster_data(services)
        raise ServiceLayer::Errors::NotImplemented
      end

      ##########################################################################
      # actions

      # Make Limes sync backend quotas/usage for the given project asynchronously.
      # Returns nothing on success.
      def sync_project_asynchronously(domain_id, project_id)
        raise ServiceLayer::Errors::NotImplemented
      end

    end
  end
end
