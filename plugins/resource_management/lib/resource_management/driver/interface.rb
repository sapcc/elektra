module ResourceManagement
  module Driver
    class Interface < Core::ServiceLayer::Driver::Base

      # List all domains that exist, as a hash of { id => name }.
      def enumerate_domains
        raise ServiceLayer::Errors::NotImplemented
      end

      # List all project IDs that exist in the given domain.
      def enumerate_project_ids(domain_id)
        raise ServiceLayer::Errors::NotImplemented
      end

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

    end
  end
end
