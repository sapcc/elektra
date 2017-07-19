module ServiceLayerNg
  # This module implements Openstack Group API
  module ResourceManagementService::CloudResource

    def find_current_cluster(query={})
      debug "[resource management-service][CloudResource] -> find_current_cluster -> GET /v1/clusters/current"
      debug "[resource management-service][CloudResource] -> find_current_cluster -> Query: #{query}"
      api.resources.get_current_cluster(query).map_to(ResourceManagement::Cluster)
    end

    def put_cluster_data(services)
      debug "[resource management-service][CloudResource] -> put_cluster_data -> PUT /v1/clusters/"
      api_client.resources.set_capacity_for_current_cluster(:cluster => {:services => services})
    end
    
  end
end