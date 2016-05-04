module ResourceManagement
  module Driver
    class Mock < Interface
      def initialize(known_projects = nil)
        @fixed_quota_values = {}
        @known_projects = known_projects
      end

      def query_project_quota(domain_id, project_id, service)
        return {} unless project_exists?(domain_id, project_id)

        result = {}
        resources_for(service).each do |resource, data_type|
          value = @fixed_quota_values[fixed_quota_key(service, resource, project_id)]
          result[resource] = value.nil? ? random_value(50, 100, data_type) : value
        end
        return result
      end

      def query_project_usage(domain_id, project_id, service)
        return {} unless project_exists?(domain_id, project_id)

        result = {}
        resources_for(service).each do |resource, data_type|
          result[resource] = random_value(0, 50, data_type)
        end
        return result
      end

      def set_project_quota(domain_id, project_id, service, values)
        return unless project_exists?(domain_id, project_id)

        values.each do |resource, value|
          @fixed_quota_values[fixed_quota_key(service, resource, project_id)] = value
        end
        return
      end

      private

      def project_exists?(domain_id, project_id)
        return true if @known_projects.nil?
        return @known_projects.find { |p| p.id == project_id && p.domain_id == domain_id }
      end

      def fixed_quota_key(service, resource, project_id)
        "#{service}:#{resource}:#{project_id}"
      end

      def resources_for(service)
        ResourceManagement::ServiceConfig.find(service).resources.map { |res| [ res.name, res.data_type ] }
      end

      def random_value(min, max, data_type)
        if data_type.to_sym == :bytes
          return rand((min << 30) .. (max << 30)) # between min and max GiB
        else
          return rand(min .. max)
        end
      end

    end
  end
end
