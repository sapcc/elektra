module ResourceManagement
  class NewStyleResource < Core::ServiceLayer::Model
    include ManualValidation

    validates_presence_of :quota
    validate :validate_quota

    def name
      read(:name).to_sym
    end

    def service_type
      read(:service_type)
    end

    def config
      return @config unless @config.nil?
      name = read(:name).to_sym
      type = read(:service_type).to_s
      return @config = ResourceManagement::ResourceConfig.all.find do |res|
        res.name == name && res.service.catalog_type == type
      end
    end

    def data_type
      Core::DataType.from_unit_name(read(:unit) || '')
    end

    def project_id
      read(:project_id)
    end
    def project_domain_id
      read(:project_domain_id)
    end
    def domain_id
      read(:domain_id)
    end
    def cluster_id
      read(:cluster_id)
    end

    def usage
      read(:usage) || 0
    end

    # domain and project only
    def quota
      read(:quota) || 0
    end
    def backend_quota
      read(:backend_quota) || nil
    end

    # domain only
    def projects_quota
      read(:projects_quota) || 0
    end

    # cluster only
    def capacity
      read(:capacity) || -1
    end
    def domains_quota
      read(:domains_quota) || 0
    end

    def save
      return self.valid? && perform_update
    end

    def perform_update
      services = [{
        type: service_type,
        resources: [{
          name: name,
          quota: quota,
        }],
      }]
      if project_id and project_domain_id
        @services_with_error = @driver.put_project_data(project_domain_id, project_id, services)
      elsif domain_id
        @driver.put_domain_data(domain_id, services)
      else
        raise ArgumentError, "found nowhere to put quota: #{attributes.inspect}"
      end
    end

    # TODO: remove this after the switch to Limes
    def services_with_error
      return @services_with_error || []
    end

    private

    def validate_quota
      errors.add(:quota, 'is below usage') if usage > quota
    end

  end
end
