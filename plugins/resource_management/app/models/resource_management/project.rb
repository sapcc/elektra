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
      read(:bursting)
    end

    def bursting_enabled
      read(:bursting)[:enabled]
    end

    def bursting_multiplier
      read(:bursting)[:multiplier]
    end

    def burst_usage
      usage = {}
      services.each do |service|
        service.resources.each do |resource|
          if resource.burst_usage > 0
            usage[service.area] = [] if usage[service.area].nil?
            usage[service.area].push({resource.name => resource.burst_usage})
          end
        end
      end
      return usage
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
        @service.put_project_data(domain_id, id, data, bursting)
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
