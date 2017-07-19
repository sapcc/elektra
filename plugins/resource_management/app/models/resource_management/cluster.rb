module ResourceManagement
  class Cluster < Core::ServiceLayerNg::Model

    def services
      metadata = {
        cluster_id: id,
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
      return resources.all?(&:valid?) && perform_update
    end

    def perform_update
      data = services.map do |srv|
        {
          type: srv.type,
          resources: srv.resources.map { |res| { name: res.name, capacity: res.capacity, comment: res.comment || '' } },
        }
      end
      @service.put_cluster_data(id, data)
    end

  end
end
