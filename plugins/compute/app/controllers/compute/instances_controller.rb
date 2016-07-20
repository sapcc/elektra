module Compute
  class InstancesController < Compute::ApplicationController
    def index
      if @scoped_project_id
        @instances = services.compute.servers
      
        # get/calculate quota data
        cores = 0
        ram = 0
        @instances.each do |i|
          flavor = i.flavor_object
          if flavor
            cores += flavor.vcpus.to_i
            ram += flavor.ram.to_i
          end
        end
      
        @quota_data = services.resource_management.quota_data([
          {service_name: 'compute', resource_name: 'instances', usage: @instances.length},
          {service_name: 'compute', resource_name: 'cores', usage: cores},
          {service_name: 'compute', resource_name: 'ram', usage: ram}
        ])
        
        #@instances.each{|i| puts i.pretty_attributes}
      end
    end

    def console
      @instance = services.compute.find_server(params[:id])
      @console = services.compute.vnc_console(params[:id])
      respond_to do |format|
        format.html{ render action: :console, layout: 'compute/console'}
        format.json{ render json: { url: @console.url }}
      end
    end

    def show
      @instance = services.compute.find_server(params[:id])
    end
    
    def new
      # get usage from db
      @quota_data = services.resource_management.quota_data([
        {service_name: 'compute', resource_name: 'instances'},
        {service_name: 'compute', resource_name: 'cores'},
        {service_name: 'compute', resource_name: 'ram'}
      ])
      
      @instance = services.compute.new_server

      @flavors            = services.compute.flavors
      @images             = services.image.images
      
      #@images.each{|i| puts i.pretty_attributes}
      #@flavors.each{|f| puts f.pretty_attributes}
      
      @availability_zones = services.compute.availability_zones
      @security_groups    = services.compute.security_groups
      @private_networks   = services.networking.project_networks(@scoped_project_id).delete_if{|n| n.attributes["router:external"]==true} if services.networking.available?
      @keypairs = services.compute.keypairs.collect {|kp| Hashie::Mash.new({id: kp.name, name: kp.name})}

      @instance.errors.add :private_network,  'not available' if @private_networks.blank?
      @instance.errors.add :image,            'not available' if @images.blank?

      @instance.flavor_id             = @flavors.first.try(:id)
      @instance.image_id              = @images.first.try(:id)
      @instance.availability_zone_id  = @availability_zones.first.try(:id)
      @instance.network_ids           = [{ id: @private_networks.first.try(:id) }]
      @instance.security_group_ids    = [{ id: @security_groups.find { |sg| sg.name == 'default' }.try(:id) }]
      @instance.keypair_id = @keypairs.first['name'] unless @keypairs.blank?

      @instance.max_count = 1            
    end


    # update instance table row (ajax call)
    def update_item
      @instance = services.compute.find_server(params[:id]) rescue nil
      @target_state = params[:target_state]

      respond_to do |format|
        format.js do
          if @instance and @instance.power_state.to_s!=@target_state
            @instance.task_state||=task_state(@target_state)
          end
        end
      end
    end

    def create
      @instance = services.compute.new_server
      @instance.attributes=params[@instance.model_name.param_key]

      if @instance.save
        flash.now[:notice] = "Instance successfully created."
        audit_logger.info(current_user, "has created", @instance)
        @instance = services.compute.find_server(@instance.id)
        render template: 'compute/instances/create.js'
      else
        @flavors = services.compute.flavors
        @images = services.image.images
        @availability_zones = services.compute.availability_zones
        @security_groups= services.compute.security_groups
        @private_networks   = services.networking.project_networks(@scoped_project_id).delete_if{|n| n.attributes["router:external"]==true}
        @keypairs = services.compute.keypairs.collect {|kp| Hashie::Mash.new({id: kp.name, name: kp.name})}
        render action: :new
      end
    end

    def new_floatingip
      @instance = services.compute.find_server(params[:id])
      collect_available_ips

      @floating_ip = Networking::FloatingIp.new(nil)
    end

    def attach_floatingip
      @instance_port = services.networking.ports(device_id: params[:id]).first
      @floating_ip = Networking::FloatingIp.new(nil,params[:floating_ip])
      
      success = begin
        @floating_ip = services.networking.attach_floatingip(params[:floating_ip][:ip_id], @instance_port.id)
        if @floating_ip.port_id
          true
        else
          false
        end
      rescue => e
        @floating_ip.errors.add('message',e.message)
        false
      end
      
      if success
        audit_logger.info(current_user, "has attached", @floating_ip, "to instance", params[:id])
        
        respond_to do |format|
          format.html{redirect_to instances_url}
          format.js{
            @instance = services.compute.find_server(params[:id])
            addresses = @instance.addresses[@instance.addresses.keys.first]
            addresses ||= []
            addresses << {
              "addr" => @floating_ip.floating_ip_address,
              "OS-EXT-IPS:type" => "floating"
            }
            @instance.addresses[@instance.addresses.keys.first] = addresses
          }
        end
      else
        collect_available_ips
        render action: :new_floatingip
      end
    end

    def detach_floatingip
      begin
        floating_ips = services.networking.project_floating_ips(@scoped_project_id, floating_ip_address: params[:floating_ip]) rescue []
        @floating_ip = services.networking.detach_floatingip(floating_ips.first.id)
      rescue => e
        flash.now[:error] = "Could not detach Floating IP. Error: #{e.message}"
      end
      
      respond_to do |format| 
        format.html{
          sleep(3)
          redirect_to instances_url
        }
        format.js{
          @instance = services.compute.find_server(params[:id])
          if @floating_ip and @floating_ip.port_id.nil?
            @instance = services.compute.find_server(params[:id])
            addresses = @instance.addresses[@instance.addresses.keys.first]
            if addresses and addresses.is_a?(Array)
              addresses.delete_if{|values| values["OS-EXT-IPS:type"]=="floating"}
            end  
            @instance.addresses[@instance.addresses.keys.first] = addresses
          end
        }
      end
    end

    def stop
      execute_instance_action
    end

    def start
      execute_instance_action
    end

    def pause
      execute_instance_action
    end

    def suspend
      execute_instance_action
    end

    def resume
      execute_instance_action
    end

    def reboot
      execute_instance_action
    end

    def destroy
      execute_instance_action('terminate')
    end

    private

    def collect_available_ips
      @networks = {}
      @available_ips = []
      services.networking.project_floating_ips(@scoped_project_id).each do |fip|
        if fip.fixed_ip_address.nil?
          unless @networks[fip.floating_network_id]
            @networks[fip.floating_network_id] = services.networking.network(fip.floating_network_id)
          end
          @available_ips << fip
        end
      end
    end

    def execute_instance_action(action=action_name)
      instance_id = params[:id]
      @instance = services.compute.find_server(instance_id) rescue nil

      @target_state=nil
      if @instance and (@instance.task_state || '')!='deleting'
        if @instance.send(action)
          audit_logger.info(current_user, "has triggered action", action, "on", @instance)
          sleep(2)
          @instance = services.compute.find_server(instance_id) rescue nil

          @target_state = target_state_for_action(action)
          @instance.task_state ||= task_state(@target_state) if @instance
        end
      end
      
      render template: 'compute/instances/update_item.js'
      #redirect_to instances_url
    end

    def target_state_for_action(action)
      case action
      when 'start' then Compute::Server::RUNNING
      when 'stop' then Compute::Server::SHUT_DOWN
      when 'shut_off' then Compute::Server::SHUT_OFF
      when 'pause' then Compute::Server::PAUSED
      when 'suspend' then Compute::Server::SUSPENDED
      when 'block' then Compute::Server::BLOCKED
      end
    end

    def task_state(target_state)
      target_state = target_state.to_i if target_state.is_a?(String)
      case target_state
      when Compute::Server::RUNNING then 'starting'
      when Compute::Server::SHUT_DOWN then 'powering-off'
      when Compute::Server::SHUT_OFF then 'powering-off'
      when Compute::Server::PAUSED then 'pausing'
      when Compute::Server::SUSPENDED then 'suspending'
      when Compute::Server::BLOCKED then 'blocking'
      when Compute::Server::BUILDING then 'creating'
      end
    end

    def active_project_id
      unless @active_project_id
        local_project = Project.find_by_domain_fid_and_fid(@scoped_domain_fid,@scoped_project_fid)
        @active_project_id = local_project.key if local_project
      end
      return @active_project_id
    end
  end
end
