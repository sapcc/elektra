module ResourceManagement
  class Project < Core::ServiceLayer::Model

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

      @services ||= read(:services).map { |data| ResourceManagement::NewStyleService.new(@driver, data.merge(metadata)) }
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
      return resources.all?(&:valid?) && perform_update
    end

    def perform_update
      data = services.map do |srv|
        {
          type: srv.type,
          resources: srv.resources.map { |res| { name: res.name, quota: res.quota } },
        }
      end
      @services_with_error = @driver.put_project_data(domain_id, id, data)
    end

    # TODO: remove this after the switch to Limes
    def services_with_error
      return @services_with_error || []
    end

  end
end
