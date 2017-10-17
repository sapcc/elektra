module ServiceLayerNg
  class ObjectStorageService < Core::ServiceLayerNg::Service

    def available?(_action_name_sym = nil)
      api.catalog_include_service?('object-store', region)
    end
    
    def capabilities
      Rails.logger.debug  "[object_storage-service] -> capabilities -> GET /info"
      response = api.object_storage.list_activated_capabilities
       map_to(ObjectStorage::Capabilities, response.body)
    end
    
    def containers
      Rails.logger.debug  "[object_storage-service] -> containers -> GET /"
      response = api.object_storage.show_account_details_and_list_containers
      map_to(ObjectStorage::ContainerNg, response.body)
    end
  end
end