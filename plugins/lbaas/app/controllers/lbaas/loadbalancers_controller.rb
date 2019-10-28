module Lbaas
  class LoadbalancersController < ::Lbaas::ApplicationController
    # set policy context
    authorization_context 'lbaas'
    # enforce permission checks. This will automatically investigate the rule name.
    authorization_required except: [:new_floatingip, :attach_floatingip, :detach_floatingip, :update_item, :get_item]

    def index

      per_page = params[:per_page] || ENTRIES_PER_PAGE
      per_page = per_page.to_i
      @loadbalancers = []

      @loadbalancers = paginatable(per_page: per_page) do |pagination_options|
        services.lbaas.loadbalancers({project_id: @scoped_project_id,sort_key: 'id'}.merge(pagination_options))
      end

      @fips = services.networking.project_floating_ips(@scoped_project_id)

      @subnets = {}
      @loadbalancers.each do |lb|
        @fips.each do |fip|
          lb.floating_ip = lb.vip_port_id == fip.port_id ? fip : nil
          break if lb.floating_ip
        end
        unless @subnets[lb.vip_subnet_id]
          @subnets[lb.vip_subnet_id] = services.networking.subnets(
            id: lb.vip_subnet_id
          ).first
        end
        lb.subnet = @subnets[lb.vip_subnet_id]
      end

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if request.xhr?
        render partial: 'list', locals: { loadbalancers: @loadbalancers }
      else
        # comon case, render index page with layout
        render action: :index
      end

    end

    def show
      @loadbalancer = services.lbaas.find_loadbalancer(params[:id])
      statuses = services.lbaas.loadbalancer_statuses(params[:id])
      @statuses = statuses.state

      hosting_agent = services.lbaas.get_loadbalancer_hosting_agent(
        params[:id]
      )

      @hosting_agent_name = hosting_agent ? hosting_agent.host : nil
    end

    # Get statuses object for one loadbalancer
    def update_status
      @states = services.lbaas.loadbalancer_statuses(params[:id])
    end

    # get statuses for all loadbalancers in project (for index)
    def update_all_status
      state_ids = params[:state_ids] || nil
      unless state_ids
        @loadbalancers = services.lbaas.loadbalancers(
          project_id: @scoped_project_id
        )
        state_ids = @loadbalancers.map(&:id)
      end

      @states = []
      state_ids.each do |id|
        status = services.lbaas.loadbalancer_statuses(id)
        @states << status if status
      end
    end

    def new
      @loadbalancer = services.lbaas.new_loadbalancer
      return unless services.networking.available?

      @private_networks = services.networking.project_networks(
        @scoped_project_id
      ).delete_if { |n| n.attributes['router:external'] == true }
    end

    def create
      @loadbalancer = services.lbaas.new_loadbalancer(
        loadbalancer_params
      )

      if @loadbalancer.save
        audit_logger.info(current_user, 'has created', @loadbalancer)
        render template: 'lbaas/loadbalancers/create.js'
        # redirect_to loadbalancers_path, notice: 'Load Balancer successfully created.'
      else
        if services.networking.available?
          @private_networks = services.networking.project_networks(
            @scoped_project_id
          ).delete_if { |n| n.attributes['router:external'] == true }
        end
        render :new
      end

      @attributes
    end

    def edit
      @loadbalancer = services.lbaas.find_loadbalancer(params[:id])
      return unless services.networking.available?
      @private_networks = services.networking.project_networks(
        @scoped_project_id
      ).delete_if { |n| n.attributes['router:external'] == true }
    end

    def update
      @loadbalancer = services.lbaas.new_loadbalancer
      @loadbalancer.id = params[:id]
      @loadbalancer.name = loadbalancer_params[:name]
      @loadbalancer.description = loadbalancer_params[:description]

      if @loadbalancer.save
        audit_logger.info(current_user, 'has updated', @loadbalancer)
        render template: 'lbaas/loadbalancers/update_item.js'
#        redirect_to loadbalancers_path, notice: 'Load Balancer was ' \
#                                                'successfully updated.'
      else
        render :edit
      end
    end

    def refresh_state
      @loadbalancer = services.lbaas.find_loadbalancer(params[:id])
      @loadbalancer.save
      render template: 'lbaas/loadbalancers/update_item.js'
    end

    def destroy
      @loadbalancer = services.lbaas.new_loadbalancer
      @loadbalancer.id = params[:id]

      if @loadbalancer.destroy
        @loadbalancer.provisioning_status = 'PENDING_DELETE'
        audit_logger.info(current_user, 'has deleted', @loadbalancer)
        flash.now[:error] = 'Load Balancer will be deleted.'
        render template: 'lbaas/loadbalancers/destroy_item.js'
      else
        flash.now[:error] = 'Load Balancer deletion failed.'
        redirect_to loadbalancers_path
      end
    end

    def new_floatingip
      @loadbalancer = services.lbaas.find_loadbalancer(params[:id])
      collect_available_ips
      @floating_ip = Networking::FloatingIp.new(nil)
    end

    def attach_floatingip
      enforce_permissions("lbaas:loadbalancer_assign_ip")
      # get loadbalancer
      @loadbalancer = services.lbaas.find_loadbalancer(params[:id])
      vip_port_id = @loadbalancer.vip_port_id

      # update floating ip with the new assigned interface ip
      @floating_ip = services.networking.new_floating_ip(params[:floating_ip])
      @floating_ip.id = params[:floating_ip][:ip_id]
      @floating_ip.port_id = vip_port_id

      if @floating_ip.save
        audit_logger.info(
          current_user, 'has attached', @floating_ip,
          'to loadbalancer', params[:id]
        )

        respond_to do |format|
          format.html { redirect_to loadbalancers_url }
          format.js {
            @loadbalancer.floating_ip = @floating_ip
          }
        end
      else
        collect_available_ips
        render action: :new_floatingip
      end
    end

    def detach_floatingip
      enforce_permissions('lbaas:loadbalancer_assign_ip')
      begin
        @floating_ip = services.networking.detach_floatingip(
          params[:floating_ip_id]
        )
      rescue => e
        flash.now[:error] = "Could not detach Floating IP. Error: #{e.message}"
      end

      respond_to do |format|
        format.html {
          sleep(3)
          redirect_to loadbalancers_url
        }
        format.js {
          if @floating_ip && @floating_ip.port_id.nil?
            @loadbalancer = services.lbaas.find_loadbalancer(params[:id])
            @loadbalancer.floating_ip = nil
          end
        }
      end
    end

    # update lb table row (ajax call)
    def update_item
      @loadbalancer = services.lbaas.find_loadbalancer(params[:id])
      @fips = services.networking.project_floating_ips(@scoped_project_id)
      @fips.each do |fip|
        @loadbalancer.floating_ip = @loadbalancer.vip_port_id == fip.port_id ? fip : nil
        break if @loadbalancer.floating_ip
      end

      respond_to do |format|
        format.js do
          @loadbalancer if @loadbalancer
        end
      end
    rescue => _e
      return nil
    end

    # used for polling state information
    def get_item
      @loadbalancer = services.lbaas.find_loadbalancer(params[:id])
      #puts ">>>>>>>>>>>>>>>>>>>>>>>>>>   #{ @loadbalancer.provisioning_status}   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
      render json: { provisioning_status: @loadbalancer.provisioning_status }
    rescue => _e
      render json: { provisioning_status: 'UNKNOWN' }
    end

    private

    def collect_available_ips
      @grouped_fips = {}
      networks = {}
      subnets = {}
      services.networking.project_floating_ips(@scoped_project_id).each do |fip|
        next unless fip.fixed_ip_address.nil?

        unless networks[fip.floating_network_id]
          networks[fip.floating_network_id] = services.networking.find_network(fip.floating_network_id)
        end
        next if networks[fip.floating_network_id].nil?

        net = networks[fip.floating_network_id]
        if !net.subnets.blank?
          net.subnets.each do |subid|
            unless subnets[subid]
              subnets[subid] = services.networking.find_subnet(subid)
            end
            sub = subnets[subid]
            cidr = NetAddr::CIDR.create(sub.cidr)

            next unless cidr.contains?(fip.floating_ip_address)
            @grouped_fips[sub.name] ||= []
            @grouped_fips[sub.name] << [fip.floating_ip_address, fip.id]
            break
          end
        else
          @grouped_fips[net.name] ||= []
          @grouped_fips[net.name] << [fip.floating_ip_address, fip.id]
        end
      end
    end

    def loadbalancer_params
      params[:loadbalancer].merge(project_id: @scoped_project_id)
    end
  end
end
