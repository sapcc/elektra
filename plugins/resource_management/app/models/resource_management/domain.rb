module ResourceManagement
  class Domain < Core::ServiceLayer::Model
    def name
      read(:name)
    end

    def services
      metadata = { domain_id: id, domain_name: name }
      metadata[:cluster_id] = read(:cluster_id) if read(:cluster_id)

      @services ||=
        read(:services).map do |data|
          ResourceManagement::NewStyleService.new(
            @service,
            data.merge(metadata),
          )
        end
    end

    def resources
      services.map(&:resources).flatten
    end

    def find_resource(service_type, resource_name)
      service_type = service_type.to_sym
      resource_name = resource_name.to_sym
      srv = services.find { |s| s.type == service_type } or return nil
      return srv.resources.find { |r| r.name == resource_name }
    end

    def save
      return resources.all?(&:valid?) && perform_update
    end

    def perform_update
      data =
        services.map do |srv|
          {
            type: srv.type,
            resources:
              srv.resources.map { |res| { name: res.name, quota: res.quota } },
          }
        end
      rescue_api_errors do
        @service.put_domain_data(read(:cluster_id), id, data)
      end
    end
  end
end
