module ResourceManagement
  class Domain < Core::ServiceLayer::Model

    def services
      metadata = {
        domain_id: id,
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

  end
end
