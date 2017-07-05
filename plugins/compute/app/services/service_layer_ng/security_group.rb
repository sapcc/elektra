module ServiceLayerNg
  # This module implements Openstack Domain API
  module SecurityGroup
    
    def security_groups_details(server_id)
      debug "[compute-service][SecurityGroup] -> security_groups_details -> GET /servers/#{server_id}/os-security-groups"
      api.compute.list_security_groups_by_server(server_id).map_to(Networking::SecurityGroupNg)
    end
  
  end
end