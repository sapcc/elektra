module Loadbalancing
  class LoadbalancersController < DashboardController
    def index
      @loadbalancers = services.loadbalancing.loadbalancers(tenant_id: @scoped_project_id)
      @fips = services.networking.project_floating_ips(@scoped_project_id)
      @loadbalancers.each do |lb|
        @fips.each do |fip|
          lb.floating_ip = lb.vip_port_id == fip.port_id ? fip : nil
          break if lb.floating_ip
        end
      end

      @quota_data = services.resource_management.quota_data([
        {service_name: :networking, resource_name: :loadbalancers, usage: @loadbalancers.length},
      ])
    end

    def show
      @loadbalancer = services.loadbalancing.find_loadbalancer(params[:id])
    end

    def new
      @loadbalancer = services.loadbalancing.new_loadbalancer
      @private_networks   = services.networking.project_networks(@scoped_project_id).delete_if{|n| n.attributes["router:external"]==true} if services.networking.available?
    end

    def create
      @loadbalancer = services.loadbalancing.new_loadbalancer()
      @loadbalancer.attributes = loadbalancer_params.delete_if{ |key,value| value.blank?}

      if @loadbalancer.save
        audit_logger.info(current_user, "has created", @loadbalancer)
        redirect_to loadbalancers_path, notice: 'Load Balancer successfully created.'
      else
        @private_networks   = services.networking.project_networks(@scoped_project_id).delete_if{|n| n.attributes["router:external"]==true} if services.networking.available?
        render :new
      end

    end

    def edit
      @loadbalancer = services.loadbalancing.find_loadbalancer(params[:id])
      @private_networks   = services.networking.project_networks(@scoped_project_id).delete_if{|n| n.attributes["router:external"]==true} if services.networking.available?
    end

    def update
      @loadbalancer = services.loadbalancing.find_loadbalancer(params[:id])
      @loadbalancer.name = loadbalancer_params[:name]
      @loadbalancer.description = loadbalancer_params[:description]
      if @loadbalancer.save
        audit_logger.info(current_user, "has updated", @loadbalancer)
        redirect_to loadbalancers_path(), notice: 'Load Balancer was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @loadbalancer = services.loadbalancing.find_loadbalancer(params[:id])
      if @loadbalancer.destroy
        audit_logger.info(current_user, "has deleted", @loadbalancer)
        flash.now[:error] = "Load Balancer will be deleted."
        redirect_to loadbalancers_path
      else
        flash.now[:error] = "Load Balancer deletion failerd."
        redirect_to loadbalancers_path
      end
    end

    def new_floatingip
      @loadbalancer = services.loadbalancing.find_loadbalancer(params[:id])
      collect_available_ips
      @floating_ip = Networking::FloatingIp.new(nil)
    end

    def attach_floatingip
      @loadbalancer = services.loadbalancing.find_loadbalancer(params[:id])
      vip_port_id = @loadbalancer.vip_port_id
      @floating_ip = Networking::FloatingIp.new(nil,params[:floating_ip])

      success = begin
        @floating_ip = services.networking.attach_floatingip(params[:floating_ip][:ip_id], vip_port_id)
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
        audit_logger.info(current_user, "has attached", @floating_ip, "to loadbalancer", params[:id])

        respond_to do |format|
          format.html{redirect_to loadbalancers_url}
          format.js{
            @loadbalancer.floating_ip = @floating_ip
          }
        end
      else
        collect_available_ips
        render action: :new_floatingip
      end
    end

    def detach_floatingip
      begin
        @floating_ip = services.networking.detach_floatingip(params[:floating_ip_id])
      rescue => e
        flash.now[:error] = "Could not detach Floating IP. Error: #{e.message}"
      end

      respond_to do |format|
        format.html{
          sleep(3)
          redirect_to loadbalancers_url
        }
        format.js{
          if @floating_ip and @floating_ip.port_id.nil?
            @loadbalancer = services.loadbalancing.find_loadbalancer(params[:id])
            @loadbalancer.floating_ip = nil
          end
        }
      end
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

    def experimental
      true
    end

    def loadbalancer_params
      return params[:loadbalancer].merge(tenant_id: @scoped_project_id)
    end

  end
end
