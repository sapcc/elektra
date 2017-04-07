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

  end
end
