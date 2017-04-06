module ResourceManagement
  class NewStyleResource < Core::ServiceLayer::Model

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

  end
end
