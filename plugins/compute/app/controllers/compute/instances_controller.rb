module Compute
  class InstancesController < Compute::ApplicationController
    def index
      if @scoped_project_id
        @instances = services.compute.servers
      end
    end

    def console
      @console = services.compute.vnc_console(params[:id])
    end

    def show
      @instance = services.compute.find_server(params[:id])
    end

    def new
      @instance = services.compute.new_server

      @flavors            = services.compute.flavors
      @images             = services.image.images
      @availability_zones = services.compute.availability_zones
      @security_groups    = services.compute.security_groups
      @private_networks   = services.networking.project_networks(@scoped_project_id).delete_if{|n| n.attributes["router:external"]==true}
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

    def execute_instance_action(action=action_name)
      instance_id = params[:id]
      @instance = services.compute.find_server(instance_id) rescue nil

      @target_state=nil
      if @instance and (@instance.task_state || '')!='deleting'
        if @instance.send(action)
          sleep(2)
          @instance = services.compute.find_server(instance_id) rescue nil

          @target_state = target_state_for_action(action)
          @instance.task_state ||= task_state(@target_state)
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
