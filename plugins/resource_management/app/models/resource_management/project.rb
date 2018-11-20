module ResourceManagement
  class Project < Core::ServiceLayer::Model

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

    def bursting
      # return fake date for testing
      return {
        enabled: true,
        multiplier: 0.2
      }
    end

    def bursting_mode
      # TODO: read bursting here if available
      return true
      read(:bursting)[:enabled]
    end

    def bursting_multiplier
      # TODO: read bursting here if available
      return 0.2
      read(:bursting)[:multiplier]
    end

    def find_resource(service_type, resource_name)
      service_type  = service_type .to_sym
      resource_name = resource_name.to_sym
      srv = services.find { |s| s.type == service_type } or return nil
      return srv.resources.find { |r| r.name == resource_name }
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

      rescue_api_errors do
        # TODO: read bursting here if available
        @service.put_project_data(domain_id, id, data, {enabled: true, multiplier: 0.2})
      end
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
