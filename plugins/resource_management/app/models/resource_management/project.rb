module ResourceManagement
  class Project < Core::ServiceLayer::Model

    def domain_id
      read(:domain_id)
    end

    def services
      metadata = {
        project_id:        id,
        project_domain_id: read(:domain_id),
      }

      @services ||= read(:services).map { |data| ResourceManagement::NewStyleService.new(@driver, data.merge(metadata)) }
    end

  end
end
