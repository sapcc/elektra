module Networking
  class FloatingIpsController < DashboardController
    # set policy context
    authorization_context 'networking'
    # enforce permission checks. This will automatically investigate the rule name.
    authorization_required

    def index
      @floating_ips = paginatable(per_page: (params[:per_page] || 20)) do |pagination_options|
        services.networking.project_floating_ips(@scoped_project_id, pagination_options.merge(sort_key: [:floating_ip_address], sort_dir: [:desc]))
      end
      #@floating_ips = services.networking.project_floating_ips(@scoped_project_id, sort_key: [:floating_ip_address], sort_dir: [:desc])
      @quota_data = services.resource_management.quota_data([
        {service_type: :network, resource_name: :floating_ips, usage: @floating_ips.length}
      ])

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if request.xhr?
        render partial: 'list', locals: {floating_ips: @floating_ips}
      else
        # comon case, render index page with layout
        render action: :index
      end
    end

    def show
      @floating_ip = services.networking.find_floating_ip(params[:id])
      @port = services.networking.find_port(@floating_ip.port_id)
      @network = services.networking.network(@floating_ip.floating_network_id)
    end

    def new
      @floating_networks = services.networking.networks('router:external' => true)
      @floating_ip = Networking::FloatingIp.new(nil)
      if @floating_networks.length==1
        @floating_ip.floating_network_id = @floating_networks.first.id
      end
    end

    def create
      @floating_networks = services.networking.networks('router:external' => true)
      @floating_ip = services.networking.new_floating_ip(params[:floating_ip])
      @floating_ip.tenant_id=@scoped_project_id

      if @floating_ip.save
        audit_logger.info(current_user, "has created", @floating_ip)
        render action: :create
      else
        render action: :new
      end
    end

    def destroy
      if services.networking.delete_floating_ip(params[:id])
        @deleted=true
        audit_logger.info(current_user, "has deleted floating ip", params[:id])
        flash.now[:notice] = "Floating IP deleted!"
      else
        @deleted=false
        flash.now[:error] = "Could not delete floating IP."
      end
    end
  end
end
