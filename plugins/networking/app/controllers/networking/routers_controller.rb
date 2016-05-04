module Networking
  class RoutersController < DashboardController
    
    # routers(filter={})
    # get_router(router_id)
    # create_router(name,params)
    # update_router(id, params)
    # delete_router(id)
    
    
    def index
      @routers = services.networking.routers(tenant_id:@scoped_project_id)
      # @router_gateway_ports = services.networking.ports(device_owner: "network:router_gateway")
      # @router_interface_ports = services.networking.ports(device_owner: "network:router_interface")
      # router_ids = []
    end

    def show
      @router = services.networking.find_router(params[:id])
      @router_gateway_ports = services.networking.ports(device_id: params[:id])
      @router_interface_ports = services.networking.ports(device_id: params[:id])
      
      @router_gateway_ports.each do |port|
        puts port.pretty_attributes
      end  
      
      @router_interface_ports.each do |port|
        puts port.pretty_attributes
      end  

      # {
      #   "status": "ACTIVE",
      #   "created_at": "2016-04-29T08:59:50",
      #   "binding:host_id": "rtmolab3",
      #   "description": "",
      #   "allowed_address_pairs": [
      #
      #   ],
      #   "admin_state_up": true,
      #   "network_id": "f2de9a68-a69e-420a-985f-65f148c72fb7",
      #   "tenant_id": "",
      #   "extra_dhcp_opts": [
      #
      #   ],
      #   "updated_at": "2016-04-29T08:59:57",
      #   "name": "",
      #   "binding:vif_type": "asr",
      #   "device_owner": "network:router_gateway",
      #   "mac_address": "fa:16:3e:11:14:6e",
      #   "binding:vif_details": {
      #     "port_filter": false
      #   },
      #   "binding:profile": {
      #   },
      #   "binding:vnic_type": "normal",
      #   "fixed_ips": [
      #     {
      #       "subnet_id": "99bd0479-d4ab-49c9-bd01-a5c1f9fc521f",
      #       "ip_address": "10.44.32.30"
      #     }
      #   ],
      #   "security_groups": [
      #
      #   ],
      #   "device_id": "9c562f2a-f329-40e3-95ed-65f6c9cf8eb2"
      # }
      # {
      #   "status": "DOWN",
      #   "created_at": "2016-04-29T09:16:41",
      #   "binding:host_id": "",
      #   "description": "",
      #   "allowed_address_pairs": [
      #
      #   ],
      #   "admin_state_up": true,
      #   "network_id": "6d6e66b4-a063-4d66-a641-15c14669f92a",
      #   "tenant_id": "a92d0be7175d4544bab86dd5d6c6ca6a",
      #   "extra_dhcp_opts": [
      #
      #   ],
      #   "updated_at": "2016-04-29T09:16:41",
      #   "name": "",
      #   "binding:vif_type": "unbound",
      #   "device_owner": "network:router_interface",
      #   "mac_address": "fa:16:3e:e1:98:12",
      #   "binding:vif_details": {
      #   },
      #   "binding:profile": {
      #   },
      #   "binding:vnic_type": "normal",
      #   "fixed_ips": [
      #     {
      #       "subnet_id": "4d44a66b-af53-4e1a-9117-ac6e9f7f2283",
      #       "ip_address": "192.168.3.1"
      #     }
      #   ],
      #   "security_groups": [
      #
      #   ],
      #   "device_id": "9c562f2a-f329-40e3-95ed-65f6c9cf8eb2"
      # }
      # {
      #   "status": "ACTIVE",
      #   "created_at": "2016-04-29T08:59:50",
      #   "binding:host_id": "rtmolab3",
      #   "description": "",
      #   "allowed_address_pairs": [
      #
      #   ],
      #   "admin_state_up": true,
      #   "network_id": "f2de9a68-a69e-420a-985f-65f148c72fb7",
      #   "tenant_id": "",
      #   "extra_dhcp_opts": [
      #
      #   ],
      #   "updated_at": "2016-04-29T08:59:57",
      #   "name": "",
      #   "binding:vif_type": "asr",
      #   "device_owner": "network:router_gateway",
      #   "mac_address": "fa:16:3e:11:14:6e",
      #   "binding:vif_details": {
      #     "port_filter": false
      #   },
      #   "binding:profile": {
      #   },
      #   "binding:vnic_type": "normal",
      #   "fixed_ips": [
      #     {
      #       "subnet_id": "99bd0479-d4ab-49c9-bd01-a5c1f9fc521f",
      #       "ip_address": "10.44.32.30"
      #     }
      #   ],
      #   "security_groups": [
      #
      #   ],
      #   "device_id": "9c562f2a-f329-40e3-95ed-65f6c9cf8eb2"
      # }
      # {
      #   "status": "DOWN",
      #   "created_at": "2016-04-29T09:16:41",
      #   "binding:host_id": "",
      #   "description": "",
      #   "allowed_address_pairs": [
      #
      #   ],
      #   "admin_state_up": true,
      #   "network_id": "6d6e66b4-a063-4d66-a641-15c14669f92a",
      #   "tenant_id": "a92d0be7175d4544bab86dd5d6c6ca6a",
      #   "extra_dhcp_opts": [
      #
      #   ],
      #   "updated_at": "2016-04-29T09:16:41",
      #   "name": "",
      #   "binding:vif_type": "unbound",
      #   "device_owner": "network:router_interface",
      #   "mac_address": "fa:16:3e:e1:98:12",
      #   "binding:vif_details": {
      #   },
      #   "binding:profile": {
      #   },
      #   "binding:vnic_type": "normal",
      #   "fixed_ips": [
      #     {
      #       "subnet_id": "4d44a66b-af53-4e1a-9117-ac6e9f7f2283",
      #       "ip_address": "192.168.3.1"
      #     }
      #   ],
      #   "security_groups": [
      #
      #   ],
      #   "device_id": "9c562f2a-f329-40e3-95ed-65f6c9cf8eb2"
      # }
      
      @topology_graph = {
        name: @router.name,
        type: 'router',
        children: @router_gateway_ports.collect{|port| {name: port.name, type: 'gateway'}} + @router_interface_ports.collect{|port| {name: port.name, type: 'network'}}
      }
    end

    #
    # def new
    #   @network = services.networking.network
    # end
    #
    # def create
    #   @network = services.networking.network
    #
    #   network_params = params[@network.model_name.param_key]
    #   subnets_params = network_params.delete(:subnets)
    #
    #   @network.attributes = network_params
    #
    #   if @network.save
    #
    #     if subnets_params
    #       subnet = services.networking.subnet
    #       subnet.attributes = subnets_params.merge("network_id"=>@network.id)
    #       puts subnet.pretty_attributes
    #       subnet.save
    #     end
    #
    #     flash[:notice] = "Network successfully created."
    #     redirect_to networks_path
    #   else
    #     render action: :new
    #   end
    # end
    #
    # def edit
    #   @network = services.networking.network(params[:id])
    # end
    #
    # def update
    #   @network = services.networking.network(params[:id])
    #   @network.attributes = params[@network.model_name.param_key]
    #   if @network.save
    #     flash[:notice] = "Network successfully updated."
    #     redirect_to networks_path
    #   else
    #     render action: :edit
    #   end
    # end
    #
    # def destroy
    #   @network = services.networking.network(params[:id]) rescue nil
    #
    #   if @network
    #     if @network.destroy
    #       flash[:notice] = "Network successfully deleted."
    #     else
    #       flash[:error] = network.errors.full_messages.to_sentence #"Something when wrong when trying to delete the project"
    #     end
    #   end
    #
    #   respond_to do |format|
    #     format.js {}
    #     format.html {redirect_to networks_path}
    #   end
    # end
  end
end
