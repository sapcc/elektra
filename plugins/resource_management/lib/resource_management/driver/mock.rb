module ResourceManagement
  module Driver
    class Mock < Interface

      def enumerate_domains
        # not really UUIDs but our code should be agnostic to that :)
        %w[ foo bar baz ]
      end

      def enumerate_projects(domain_id)
        %w[ foo bar baz qux ].map { |stem| "#{domain_id}_#{stem}" }
      end

      def query_project_quota(domain_id, project_id, service)
        result = {}
        resources_for(service).each do |resource, data_type|
          result[resource] = random_value(50, 100, data_type)
        end
        return result
      end

      def query_project_usage(domain_id, project_id, service)
        result = {}
        resources_for(service).each do |resource, data_type|
          result[resource] = random_value(0, 50, data_type)
        end
        return result
      end

      private

      def resources_for(service)
        ResourceManagement::Resource::KNOWN_RESOURCES.
          select { |res| res[:service] == service }.
          map    { |res| [ res[:name], res[:data_type] ] }
      end

      def random_value(min, max, data_type)
        if data_type == :bytes
          return rand(min .. (max << 30)) # between min and max GiB
        else
          return rand(min .. max)
        end
      end

    end
  end
end
