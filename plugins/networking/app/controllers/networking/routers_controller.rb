module Networking
  class RoutersController < DashboardController
    
    def index
      @routers = services.networking.routers(tenant_id:@scoped_project_id)
    end

    def topology
      @router = services.networking.find_router(params[:router_id])
      @router_gateway_ports = services.networking.ports(device_id: @router.id, device_owner: "network:router_gateway")
      @router_interface_ports = services.networking.ports(device_id: @router.id, device_owner: "network:router_interface")
      
      @topology_graph = {
        name: @router.name,
        type: 'router',
        children: @router_gateway_ports.collect{|port| {name: port.name, type: 'gateway'}} + @router_interface_ports.collect{|port| {name: port.name, type: 'network'}}
      }
    end
    
    def show
      @router = services.networking.find_router(params[:id])
      ports = services.networking.ports(device_id: params[:id])
      
      @router_gateway_ports = []#services.networking.ports(device_id: params[:id], device_owner: "network:router_gateway")
      @router_interface_ports = []#services.networking.ports(device_id: params[:id], device_owner: "network:router_interface", tenant_id: @scoped_project_id)
      
      
      ports.each do |port|
        puts port.pretty_attributes
        if port.device_owner=='network:router_gateway'
          @router_gateway_ports << port
        elsif port.device_owner=='network:router_interface'
          @router_interface_ports << port
        end
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
    end

    def new
      # build new router object (no api call done yet!)
      @router = services.networking.new_router("admin_state_up" => true)      
      
      networks = available_networks    
      @external_networks = networks[:external_networks]
      @internal_subnets = networks[:internal_subnets]
    end

    def create
      # get selected subnets and remove them from params
      @selected_internal_subnets = (params[:router].delete(:internal_subnets) || []).reject { |c| c.empty? }
      # build new router object
      @router = services.networking.new_router(params[:router])

      if @router.save
        # router is created -> add subnets as interfaces
        services.networking.add_router_interfaces(@router.id,@selected_internal_subnets)
        
        flash.now[:notice] = "Router successfully created."
        redirect_to plugin('networking').routers_path
      else
        # didn't save -> render new
        networks = available_networks    
        @external_networks = networks[:external_networks]
        @internal_subnets = networks[:internal_subnets]
        render action: :new
      end
    end

    def edit
      @router = services.networking.find_router(params[:id])
      @external_network = services.networking.network(@router.external_gateway_info["network_id"])
      
      # load all project networks
      project_networks = services.networking.project_networks(@scoped_project_id)
      
      @external_networks = []
      @internal_subnets = []
      
      project_networks.each do |network| 
        if network.attributes["router:external"]==true
          @external_networks << network
        else
          network.subnet_objects.each do |subnet|
            # add if not attached
            @internal_subnets << subnet
          end
        end
      end
      
      attached_ports = services.networking.ports(device_id: @router.id, device_owner:'network:router_interface')
      @selected_internal_subnet_ids = attached_ports.inject([]){|array,port| port.fixed_ips.each{|ip| array << ip["subnet_id"]}; array}
    end

    def update
      # get selected subnets and remove them from params
      params[:router].delete(:external_gateway_info)
      @selected_internal_subnet_ids = (params[:router].delete(:internal_subnets) || []).reject { |c| c.empty? }
      # build new router object
      @router = services.networking.find_router(params[:id])
      @router.name = params[:router][:name]
      @router.admin_state_up = params[:router][:admin_state_up]

      if @router.save
        attached_ports = services.networking.ports(device_id: @router.id, device_owner:'network:router_interface')
        @old_selected_internal_subnet_ids = attached_ports.inject([]){|array,port| port.fixed_ips.each{|ip| array << ip["subnet_id"]}; array}
        
        to_be_detached = (@old_selected_internal_subnet_ids-@selected_internal_subnet_ids)
        to_be_attached = (@selected_internal_subnet_ids-@old_selected_internal_subnet_ids)

        services.networking.remove_router_interfaces(@router.id,to_be_detached)
        services.networking.add_router_interfaces(@router.id,to_be_attached)
        
        flash.now[:notice] = "Router successfully created."
        redirect_to plugin('networking').routers_path
      else
        @external_network = services.networking.network(@router.external_gateway_info["network_id"])
      
        # load all project networks
        project_networks = services.networking.project_networks(@scoped_project_id)
      
        @external_networks = []
        @internal_subnets = []
      
        project_networks.each do |network| 
          if network.attributes["router:external"]==true
            @external_networks << network
          else
            network.subnet_objects.each do |subnet|
              # add if not attached
              @internal_subnets << subnet
            end
          end
        end
        render action: :new
      end
    end

    def destroy
      @router = services.networking.find_router(params[:id]) rescue nil
      ports = services.networking.ports(device_owner:'network:router_interface',device_id: @router.id)
      
      @success = false
      if @router
        attached_subnet_ids = (ports || []).inject([]){|array,port| port.fixed_ips.each{|ip| array << ip["subnet_id"]}; array}
        
        services.networking.remove_router_interfaces(@router.id,attached_subnet_ids)
        if @router.destroy
          @success = true
          flash.now[:notice] = "Router successfully deleted."
        else
          flash.now[:error] = network.errors.full_messages.to_sentence #"Something when wrong when trying to delete the project"
        end
      end

      respond_to do |format|
        format.js {}
        format.html {redirect_to routers_path}
      end
    end
    
    protected
    def attached_subnet_ids
      # get all router attached ports
      ports = services.networking.ports(device_owner:'network:router_interface',tenant_id:@scoped_project_id)
      # get subnet ids
      @attached_subnet_ids ||= (ports || []).inject([]){|array,port| port.fixed_ips.each{|ip| array << ip["subnet_id"]}; array}
    end
    
    def available_networks
      # load all project networks
      project_networks = services.networking.project_networks(@scoped_project_id)
      # get external and internal networks
      return @available_networks if @available_networks
      
      @available_networks = { external_networks: [], internal_subnets: [] }
      project_networks.each do |network| 
        if network.attributes["router:external"]==true
          @available_networks[:external_networks] << network
        else
          network.subnet_objects.each do |subnet|
            # add if not attached
            @available_networks[:internal_subnets] << subnet unless attached_subnet_ids.include?(subnet.id)
          end
        end
      end
      @available_networks
    end
    
  end
end
