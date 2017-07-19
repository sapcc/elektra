module ResourceManagement
  class NewStyleService < Core::ServiceLayerNg::Model

    def type
      read(:type).to_sym
    end

    def project_id
      read(:project_id)
    end
    def project_name
      read(:project_name)
    end
    def project_domain_id
      read(:project_domain_id)
    end
    def domain_id
      read(:domain_id)
    end
    def domain_name
      read(:domain_name)
    end
    def cluster_id
      read(:cluster_id)
    end

    def resources
      metadata = {
        service_type:      read(:type).to_sym,
        project_id:        read(:project_id),
        project_name:      read(:project_name),
        project_domain_id: read(:project_domain_id),
        domain_id:         read(:domain_id),
        domain_name:       read(:domain_name),
        cluster_id:        read(:cluster_id),
      }.reject { |k,v| v.nil? }

      @resources ||= read(:resources).map { |data| ResourceManagement::NewStyleResource.new(@service, data.merge(metadata)) }
    end

    def updated_at
      tst = read(:scraped_at)
      tst ? Time.at(tst) : nil
    end

    def min_updated_at
      tst = read(:min_scraped_at)
      tst ? Time.at(tst) : nil
    end
    def max_updated_at
      tst = read(:max_scraped_at)
      tst ? Time.at(tst) : nil
    end

  end
end
