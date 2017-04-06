module ResourceManagement
  class Project < Core::ServiceLayer::Model

    def id
      read(:id)
    end

    def domain_id
      read(:domain_id)
    end

    def services
      metadata = {
        project_id:        read(:id),
        project_domain_id: read(:domain_id),
      }
      read(:services).map { |data| ResourceManagement::NewStyleService.new(@driver, data.merge(metadata)) }
    end

  end
end
