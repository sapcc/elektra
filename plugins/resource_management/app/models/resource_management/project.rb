module ResourceManagement
  class Project < Core::ServiceLayer::Model

    def id
      read(:id)
    end

    def services
      project_id = read(:id)
      read(:services).map { |data| ResourceManagement::NewStyleService.new(@driver, data.merge(project_id: project_id)) }
    end

  end
end
