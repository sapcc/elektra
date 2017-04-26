module Networking
  class NetworksController < DashboardController
    before_filter :load_type, except: [:subnets]
    def index
      filter_options = {
        'router:external' => @network_type == 'external',
        sort_key: 'name'
      }
      @networks = paginatable(per_page: 15) do |pagination_options|
        services.networking.networks(filter_options.merge(pagination_options))
      end

      # all networks but shared
      usage = @networks.select { |n| n.shared == false }.length
      @quota_data = services.resource_management.quota_data([
        {service_type: :network, resource_name: :networks, usage: usage}
      ])
    end

    def show
      @network = services.networking.network(params[:id])
      @subnets = services.networking.subnets(network_id: @network.id)
      @ports   = services.networking.ports(network_id: @network.id)
    end

    def new
      @network = services.networking.new_network(name: "#{@scoped_project_name}_#{@network_type}")
      @subnet = Networking::Subnet.new(nil,name: "#{@network.name}_sub", enable_dhcp: true)
    end

    def create
      network_params = params[:network]
      subnets_params = network_params.delete(:subnets)
      @network = services.networking.new_network(network_params)
      @errors = Array.new

      if @network.save
        if subnets_params.present?
          @subnet = services.networking.new_subnet(subnets_params)
          @subnet.network_id = @network.id

          # FIXME: anti-pattern of doing two things in one action
          if @subnet.save
            flash[:keep_notice_htmlsafe] = "Network #{@subnet.name} successfully created.<br /> <strong>Please note:</strong> If you want to attach floating IPs to objects in this network you will need to #{view_context.link_to('create a router', plugin('networking').routers_path)} connecting this network to the floating IP network."
            audit_logger.info(current_user, "has created", @network)
            audit_logger.info(current_user, "has created", @subnet)
            redirect_to plugin('networking').send("networks_#{@network_type}_index_path")
          else
            @network.destroy
            @errors = @subnet.errors
            render action: :new
          end
        else
          audit_logger.info(current_user, "has created", @network)
          redirect_to plugin('networking').send("networks_#{@network_type}_index_path")
        end

      else
        @errors = @network.errors
        render action: :new
      end
    end

    def edit
      @network = services.networking.network(params[:id])
    end

    def update
      @network = services.networking.network(params[:id])
      @network.attributes = params[@network.model_name.param_key]
      if @network.save
        flash[:notice] = 'Network successfully updated.'
        audit_logger.info(current_user, "has updated", @network)
        redirect_to plugin('networking').send("networks_#{@network_type}_index_path")
      else
        render action: :edit
      end
    end

    def destroy
      @network = services.networking.network(params[:id]) rescue nil

      if @network
        if @network.destroy
          audit_logger.info(current_user, "has deleted", @network)
          flash[:notice] = 'Network successfully deleted.'
        else
          flash[:error] = @network.errors.full_messages.to_sentence
        end
      end

      respond_to do |format|
        format.js {}
        format.html { redirect_to plugin('networking').send("networks_#{@network_type}_index_path") }
      end
    end

    def subnets
      availability = service_user.cloud_admin_service(:networking).network_ip_availability(params[:network_id]) rescue nil
      # subnets = services.networking.subnets(network_id: params[:network_id])
      #render json: services.networking.subnets(network_id: params[:network_id])
      # byebug
      render json: availability.nil? ? [] : availability.subnet_ip_availability
    end

    private

    def load_type
      raise 'has to be implemented in subclass'
    end
  end
end
