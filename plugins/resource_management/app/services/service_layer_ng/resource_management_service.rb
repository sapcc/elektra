module ServiceLayerNg

  class ResourceManagementService < Core::ServiceLayerNg::Service

    include ResourceManagementService::ProjectResource
    include ResourceManagementService::DomainResource
    include ResourceManagementService::CloudResource

    def available?(_action_name_sym = nil)
      api.catalog_include_service?('resources', region)
    end

  end
end
