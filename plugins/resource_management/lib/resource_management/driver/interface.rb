module ResourceManagement
  module Driver
    class Interface < Core::ServiceLayer::Driver::Base

      ##########################################################################
      # old-style interface

      # Query quotas for the given project from the given service.
      # Returns a hash with resource names as keys. The service argument and
      # the resource names in the result are symbols, with acceptable values
      # defined in ResourceManagement::{ResourceConfig,ServiceConfig}.
      def query_project_quota(domain_id, project_id, service)
        raise ServiceLayer::Errors::NotImplemented
      end

      # Query usage values for the given project from the given service.
      # Returns a hash with resource names as keys. The service argument and
      # the resource names in the result are symbols, with acceptable values
      # defined in ResourceManagement::{ResourceConfig,ServiceConfig}.
      def query_project_usage(domain_id, project_id, service)
        raise ServiceLayer::Errors::NotImplemented
      end

      # Set quotas for the given project in the given service. `values` must be
      # a hash with resource names as keys. The service argument and resource
      # names are symbols, with acceptable values defined in
      # ResourceManagement::{ResourceConfig,ServiceConfig}.
      def set_project_quota(domain_id, project_id, service, values)
        raise ServiceLayer::Errors::NotImplemented
      end

      ##########################################################################
      # new-style interface

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

    end
  end
end
