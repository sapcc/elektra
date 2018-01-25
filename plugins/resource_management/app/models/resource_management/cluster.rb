module ResourceManagement
  class Cluster < Core::ServiceLayer::Model

    def services
      metadata = {
        cluster_id: id,
      }

      @services ||= read(:services).map { |data| ResourceManagement::NewStyleService.new(@service, data.merge(metadata)) }
    end

    def resources
      services.map(&:resources).flatten
    end

    def find_resource(service_type, resource_name)
      service_type  = service_type .to_sym
      resource_name = resource_name.to_sym
      srv = services.find { |s| s.type == service_type } or return nil
      return srv.resources.find { |r| r.name == resource_name }
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
      rescue_api_errors do
        @service.put_cluster_data(id, data)
      end
    end

  end
end
