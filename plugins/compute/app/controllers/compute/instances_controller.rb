module Compute
  class InstancesController < Compute::ApplicationController
    before_filter :all_projects

    authorization_context 'compute'
    authorization_required

    def index
      @instances = []
      if @scoped_project_id
        @instances = paginatable(per_page: 10) do |pagination_options|
          services.compute.servers(@admin_option.merge(pagination_options))
        end

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
          {service_name: :compute, resource_name: :instances, usage: @instances.length},
          {service_name: :compute, resource_name: :cores, usage: cores},
          {service_name: :compute, resource_name: :ram, usage: ram}
        ])
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
      @instance_security_groups = @instance.security_groups.collect do |sg|
        services.networking.security_groups(tenant_id: @scoped_project_id, name: sg['name']).first
      end
    end

    def new
      # get usage from db
      @quota_data = services.resource_management.quota_data([
        {service_name: :compute, resource_name: :instances},
        {service_name: :compute, resource_name: :cores},
        {service_name: :compute, resource_name: :ram}
      ])

      @instance = services.compute.new_server

      @flavors            = services.compute.flavors
      @images             = services.image.images

      @availability_zones = services.compute.availability_zones
      @security_groups = services.networking.security_groups(tenant_id: @scoped_project_id)
      @private_networks   = services.networking.project_networks(@scoped_project_id).delete_if{|n| n.attributes["router:external"]==true} if services.networking.available?
      @keypairs = services.compute.keypairs.collect {|kp| Hashie::Mash.new({id: kp.name, name: kp.name})}

      @instance.errors.add :private_network,  'not available' if @private_networks.blank?
      @instance.errors.add :image,            'not available' if @images.blank?

      @instance.flavor_id             = @flavors.first.try(:id)
      @instance.image_id              = params[:image_id] || @images.first.try(:id)
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
      params[:server][:security_groups] = params[:server][:security_groups].delete_if{|sg| sg.empty?}
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
        @security_groups = services.networking.security_groups(tenant_id: @scoped_project_id)
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

    def attach_interface
      @os_interface = services.compute.new_os_interface(params[:id])
      @networks = services.networking.networks("router:external"=>false)
    end

    def create_interface
      @os_interface = services.compute.new_os_interface(params[:id],params[:os_interface])
      if @os_interface.save
        @instance = services.compute.find_server(params[:id])
        respond_to do |format|
          format.html{redirect_to instances_url}
          format.js{}
        end
      else
        @networks = services.networking.networks("router:external"=>false)
        render action: :attach_interface
      end
    end

    def detach_interface
      @instance = services.compute.find_server(params[:id])
      @os_interface = services.compute.new_os_interface(params[:id])
    end

    def delete_interface
      # create a new os_interface model based on params
      @os_interface = services.compute.new_os_interface(params[:id],params[:os_interface])

      # load all attached server interfaces
      all_server_interfaces = services.compute.server_os_interfaces(params[:id])
      # find the one which should be deleted
      interface = all_server_interfaces.find do |i|
        i.fixed_ips.first['ip_address']==@os_interface.ip_address
      end

      success = if interface
        # destroy
        @os_interface.id = @os_interface.port_id = interface.port_id
        @os_interface.destroy
      else
        @os_interface.errors.add(:address,'Not found.')
        false
      end

      if success
        # load instance after deleting os interface!!!

        # try to update instance state
        timeout = 60
        sleep_time = 3
        loop do
          @instance = services.compute.find_server(params[:id])
          if timeout<=0 or @instance.addresses.values.flatten.length==all_server_interfaces.length-1
            break
          else
            timeout -= sleep_time
            sleep(sleep_time)
          end
        end
        respond_to do |format|
          format.html{redirect_to instances_url}
          format.js{}
        end
      else
        @instance = services.compute.find_server(params[:id])
        @os_interface.ip_address=params[:os_interface][:ip_address]
        render action: :detach_interface
      end
    end

    def new_size
      @instance = services.compute.find_server(params[:id])
      @flavors  = services.compute.flavors
    end

    def resize
      @close_modal=true
      execute_instance_action('resize',params[:server][:flavor_id])
    end

    def new_snapshot
    end

    def create_image
      @close_modal=true
      execute_instance_action('create_image',params[:snapshot][:name])
    end

    def confirm_resize
      execute_instance_action
    end

    def revert_resize
      execute_instance_action
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

    def execute_instance_action(action=action_name,options=nil)
      instance_id = params[:id]
      @instance = services.compute.find_server(instance_id) rescue nil

      @target_state=nil
      if @instance and (@instance.task_state || '')!='deleting'
        result = options.nil? ? @instance.send(action) : @instance.send(action,options)
        if result
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

    private

    def all_projects
      @all_projects = current_user.is_allowed?('compute:all_projects')
      @admin_option = @all_projects ? { all_tenants: 1 } : {}
    end
  end
end
