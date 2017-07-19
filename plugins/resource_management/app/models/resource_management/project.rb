module ResourceManagement
  class Project < Core::ServiceLayerNg::Model

    validate :validate_resources

    def name
      read(:name)
    end

    def domain_id
      read(:domain_id)
    end

    def services
      metadata = {
        project_id:        id,
        project_domain_id: read(:domain_id),
        project_name:      name,
      }

      @services ||= read(:services).map { |data| ResourceManagement::NewStyleService.new(@service, data.merge(metadata)) }
    end

    def resources
      services.map(&:resources).flatten
    end

    def find_resource(config)
      service_type = config.service.catalog_type.to_sym
      srv = services.find { |s| s.type == service_type } or return nil
      return srv.resources.find { |r| r.name == config.name }
    end

    def save
      return self.valid? && perform_update
    end

    def perform_update
      data = services.map do |srv|
        {
          type: srv.type,
          resources: srv.resources.map { |res| { name: res.name, quota: res.quota } },
        }
      end
      @service.put_project_data(domain_id, id, data)
    end

    private

    def validate_resources
      resources.each do |res|
        next if res.valid?
        errors.add("resource #{res.service_type}/#{res.name}", "is broken: #{res.errors.full_messages.to_sentence}")
      end
    end

  end
end
