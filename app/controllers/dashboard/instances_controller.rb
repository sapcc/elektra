module Dashboard
  class InstancesController < DashboardController

    def index
      @active_domain = services.identity.find_domain(@scoped_domain_id)

      if @scoped_project_id
        @instances = services.compute.servers.all
      end
    end

    def show
      @instance = services.compute.servers.get(params[:id])
      @flavor = services.compute.flavors.get(@instance.flavor.fetch("id",nil))
      @image = services.compute.images.get(@instance.image.fetch("id",nil))
    end

    def new
      @forms_instance = services.compute.forms_instance
      @flavors = services.compute.flavors
      @images = services.image.images

      @forms_instance.flavor=@flavors.first.id
      @forms_instance.image=@images.first.id
    end


    # update instance table row (ajax call)
    def update_item
      #@instance = services.compute.find_instance(params[:id])
      instances = services.compute.servers.all(changes_since: Time.now-2.seconds)
      @instance = instances.find{|i|i.id==params[:id]}

      @target_state = params[:target_state]

      respond_to do |format|
        format.js do

          if @instance and @instance.os_ext_sts_power_state.to_s!=@target_state
            @instance.os_ext_sts_task_state||=task_state(@target_state)
          end
        end
      end
    end

    def create
      @forms_instance = services.compute.forms_instance(params[:id])
      @forms_instance.attributes=params[:forms_instance]

      if @forms_instance.save
        flash[:notice] = "Instance successfully created."
        redirect_to instances_path
      else
        @flavors = services.compute.flavors
        @images = services.image.images
        render action: :new
      end
    end

    def edit
      @forms_instance = services.compute.forms_instance(params[:id])
      respond_to do |format|
        format.html {}
        format.js
      end
    end

    def update

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


    def destroy
      execute_instance_action
      # @forms_instance = services.compute.forms_instance(params[:id])
      #
      # if @forms_instance.destroy
      #   flash[:notice] = "instance is terminating"
      # else
      #   flash[:notice] = "Could not delete instance."
      # end
      # redirect_to instances_url

    end

    private

    def execute_instance_action(action=action_name)
      instance_id = params[:id]
      @instance = services.compute.find_instance(instance_id)

      @target_state=nil
      if (@instance.os_ext_sts_task_state || '')!='deleting'
        if @instance.send(action)
          sleep(2)
          instances = services.compute.servers.all
          @instance = instances.find{|i|i.id==instance_id}

          @target_state = target_state_for_action(action)
          @instance.os_ext_sts_task_state ||= task_state(@target_state)
        end
      end
      render template: 'dashboard/instances/update_item.js'
      #redirect_to instances_url
    end

    def target_state_for_action(action)
      case action
      when 'start' then Fog::Compute::OpenStack::Server::RUNNING
      when 'stop' then Fog::Compute::OpenStack::Server::SHUT_DOWN
      when 'shut_off' then Fog::Compute::OpenStack::Server::SHUT_OFF
      when 'pause' then Fog::Compute::OpenStack::Server::PAUSED
      when 'suspend' then Fog::Compute::OpenStack::Server::SUSPENDED
      when 'block' then Fog::Compute::OpenStack::Server::BLOCKED
      end
    end

    def task_state(target_state)
      target_state = target_state.to_i if target_state.is_a?(String)
      case target_state
      when Fog::Compute::OpenStack::Server::RUNNING then 'starting'
      when Fog::Compute::OpenStack::Server::SHUT_DOWN then 'powering-off'
      when Fog::Compute::OpenStack::Server::SHUT_OFF then 'powering-off'
      when Fog::Compute::OpenStack::Server::PAUSED then 'pausing'
      when Fog::Compute::OpenStack::Server::SUSPENDED then 'suspending'
      when Fog::Compute::OpenStack::Server::BLOCKED then 'blocking'
      when Fog::Compute::OpenStack::Server::BUILDING then 'creating'
      end
    end
  end

end
