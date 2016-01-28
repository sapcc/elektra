module ResourceManagement
  module Driver
    class Mock < Interface
      attr_reader :mock_domains_projects

      def initialize
        @mock_domains_projects = {
          # hash of domain_id => { hash of project_id => project_name }
          '7d11af29-7055-40a5-a575-c5de2e6b5973' => {
            name: 'foodomain',
            projects: {
              '25301b18-d7ee-4fe0-a360-8d5280bec593' => 'fooproject',
              '92ceb1f6-c5e1-4001-9893-f321f34eb6b9' => 'barproject',
            },
          },
          'f45b7b16-e6ec-4255-9fc5-90304c1f3b57' => {
            name: 'quxdomain',
            projects: {
              '0b9147f6-5454-4afd-8e03-39e44f2b2842' => 'quxproject',
            },
          },
        }
      end

      def enumerate_domains
        result = {}
        @mock_domains_projects.each_pair do |id,hash|
          result[id] = hash[:name]
        end
        return result
      end

      def enumerate_projects(domain_id)
        @mock_domains_projects.fetch(domain_id, {}).fetch(:projects, {})
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

      def set_project_quota(domain_id, project_id, service, values)
        @set_calls ||= []
        @set_calls.push(
          domain_id: domain_id,
          project_id: project_id,
          service: service,
          values: values,
        )
        return
      end

      def set_call_history
        return @set_calls
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
