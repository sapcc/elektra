module ResourceManagement
  module Driver
    class Interface < DomainModelServiceLayer::Driver::Base

      # List all domain IDs that exist.
      def enumerate_domains
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      # List all project IDs that exist in the given domain.
      def enumerate_projects(domain_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      # Query quotas for the given project from the given service.
      # Returns a hash with resource names as keys. The service argument and
      # the resource names in the result are symbols, with acceptable values
      # defined in ResourceManagement::Resource::KNOWN_RESOURCES.
      def query_project_quota(domain_id, project_id, service)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      # Query usage values for the given project from the given service.
      # Returns a hash with resource names as keys. The service argument and
      # the resource names in the result are symbols, with acceptable values
      # defined in ResourceManagement::Resource::KNOWN_RESOURCES.
      def query_project_usage(domain_id, project_id, service)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

    end
  end
end
