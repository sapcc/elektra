# frozen_string_literal: true

module Networking
  # Implements Router actions
  class RoutersController < DashboardController
    before_action :fill_available_networks, only: %i[new create edit update]

    def index
      ################# NEW
      @routers = []
      @quota_data = []

      if current_user.is_allowed?('context_is_cloud_network_admin')
        @routers = services.networking.routers(sort_key: 'name', sort_dir: 'asc')
      else
        # find routers of shared networks
        private_shared_networks = services.networking.networks(
          'router:external' => false, 'shared' => true
        )

        shared_routers = private_shared_networks.each_with_object([]) do |n, arr|
          ports = cloud_admin.networking.ports(
            device_owner: 'network:router_interface', network_id: n.id, tenant_id: n.tenant_id
          )
          ports.each do |port|
            router = cloud_admin.networking.find_router(port.device_id)
            arr << router if router
          end
        end.flatten.uniq
        ################## END
        @routers = services.networking.routers(tenant_id: @scoped_project_id)

        # NEW
        @routers.concat(shared_routers).uniq!(&:id)

      end
    end

    def topology
      @router = cloud_admin.networking.find_router(params[:router_id])
      @external_network = cloud_admin.networking.find_network(
        @router.external_gateway_info['network_id']
      )
      @router_interface_ports = cloud_admin.networking.ports(
        device_id: @router.id, device_owner: 'network:router_interface'
      )

      @topology_graph = {
        name: @router.name,
        type: 'router',
        id: @router.id,
        children: [{
          name: @external_network.name,
          type: 'gateway',
          id: @external_network.id
        }] + @router_interface_ports.collect do |port|
          node = { name: port.network_object.name, type: 'network',
                   id: port.network_object.id }
          cloud_admin.networking.ports(network_id: port.network_id, status: 'ACTIVE').each do |np|
            if np.device_owner.start_with?('compute:')
              node[:children] ||= []
              node[:children] << { name: '', type: 'server', id: np.device_id }
            end
          end
          node
        end
      }
    end

    def node_details
      case params[:type]
      when 'router'
        render partial: 'networking/routers/node_details/router',
               locals: {
                 router: services.networking.find_router(params[:router_id])
               }
      when 'network'
        render partial: 'networking/routers/node_details/network',
               locals: { network: services.networking.find_network(params[:id]) }
      when 'gateway'
        render partial: 'networking/routers/node_details/gateway',
               locals: {
                 external_network: services.networking.find_network(params[:id])
               }
      when 'server'
        server = services.compute.find_server(params[:id])
        port = services.networking.ports(device_id: server.id).first if server
        render partial: 'networking/routers/node_details/server',
               locals: { server: server, port: port },
               status: server.nil? ? 404 : 200
      else
        render plain: 'No details available'
      end
    end

    def show
      @router = cloud_admin.networking.find_router(params[:id])
      @external_network = cloud_admin.networking.find_network(
        @router.external_gateway_info['network_id']
      )
      @router_interface_ports = cloud_admin.networking.ports(
        device_id: @router.id, device_owner: 'network:router_interface'
      )
    end

    def new
      @quota_data = []
      if current_user.is_allowed?('access_to_project')
        @quota_data = services.resource_management.quota_data(
          current_user.domain_id || current_user.project_domain_id,
          current_user.project_id,
          [
            { service_type: :network, resource_name: :routers }
          ]
        )
      end

      # build new router object (no api call done yet!)
      @router = services.networking.new_router('admin_state_up' => true)
    end

    def create
      # get selected subnets and remove them from params
      @selected_internal_subnets = (
        params[:router].delete(:internal_subnets) || []
      ).reject(&:empty?)
      # build new router object
      @router = services.networking.new_router(params[:router])
      @router.internal_subnets = @selected_internal_subnets

      if @router.save
        # router is created -> add subnets as interfaces
        services.networking.add_router_interfaces(
          @router.id, @selected_internal_subnets
        )
        audit_logger.info(current_user, 'has created', @router)

        flash.now[:notice] = 'Router successfully created.'
        redirect_to plugin('networking').routers_path
      else
        # didn't save -> render new
        render action: :new
      end
    end

    def edit
      @action_from_show = params[:action_from_show] || 'false'
      @router = services.networking.find_router(params[:id])
      @external_network = services.networking.find_network(
        @router.external_gateway_info['network_id']
      )
      @router_interface_ports = services.networking.ports(
        device_id: @router.id, device_owner: 'network:router_interface'
      )
      @router_internal_subnet_ids = @router_interface_ports
                                    .each_with_object([]) do |port, array|
        (port.fixed_ips || []).each { |fixed_ip| array << fixed_ip['subnet_id'] }
      end
      @router_external_subnet_ids = if @router.external_gateway_info['external_fixed_ips'].nil?
                                      []
                                    else
                                      @router.external_gateway_info['external_fixed_ips'].collect { |data| data['subnet_id'] }
      end
    end

    def update
      @action_from_show = params[:router].delete(:action_from_show) == 'true' || false
      # get selected subnets and remove them from params
      @selected_internal_subnet_ids = (
        params[:router].delete(:internal_subnets) || []
      ).reject(&:empty?)

      # build new router object
      @router = services.networking.new_router(params[:router].to_unsafe_hash)
      @router.id = params[:id]

      if params[:router][:external_gateway_info].blank? ||
         params[:router][:external_gateway_info][:network_id].blank?
        @router.external_gateway_info = {}
      else
        @router.external_gateway_info = params[:router][:external_gateway_info].to_unsafe_hash
      end

      # <ActionController::Parameters {"utf8"=>"✓", "_method"=>"put", "router"=><ActionController::Parameters {"name"=>"test router qa", "external_gateway_info"=><ActionController::Parameters {"network_id"=>"430991b3-da0d-41cb-ac54-d1d532841725", "external_fixed_ips"=>[{"subnet_id"=>"c62a3c29-9fb0-4604-bf61-b8f8ff6c6777"}]} permitted: false>} permitted: false>, "button"=>"", "modal"=>"true", "domain_id"=>"monsoon3", "project_id"=>"andreas-pfau", "controller"=>"networking/routers", "action"=>"update", "id"=>"72e8afbd-f272-48ed-ac22-b87602981718"} permitted: false>

      @router.internal_subnets = @selected_internal_subnet_ids

      @external_network = services.networking.find_network(
        @router.external_gateway_info['network_id']
      )

      if @router.save
        attached_ports = services.networking.ports(
          device_id: @router.id, device_owner: 'network:router_interface'
        )
        @old_selected_internal_subnet_ids = attached_ports.each_with_object([]) do |port, array|
          port.fixed_ips.each { |ip| array << ip['subnet_id'] }
        end

        to_be_detached = (@old_selected_internal_subnet_ids - @selected_internal_subnet_ids)
        to_be_attached = (@selected_internal_subnet_ids - @old_selected_internal_subnet_ids)

        @router.remove_interfaces(to_be_detached)
        @router.add_interfaces(to_be_attached)
      end

      if @router.errors.empty?
        audit_logger.info(current_user, 'has updated', @router)

        flash.now[:notice] = 'Router successfully created.'

        if @action_from_show
          redirect_to plugin('networking').router_path(@router.id)
        else
          redirect_to plugin('networking').routers_path
        end
      else
        @external_network = services.networking.find_network(@router.external_gateway_info['network_id'])

        render action: :edit
      end
    end

    def destroy
      @action_from_show = params[:action_from_show] == 'true' || false
      @router = services.networking.new_router
      @router.id = params[:id]
      ports = services.networking.ports(
        device_owner: 'network:router_interface', device_id: @router.id
      ) || []

      @success = true

      if @router
        attached_subnet_ids = ports.each_with_object([]) do |port, array|
          port.fixed_ips.each { |ip| array << ip['subnet_id'] }
        end

        services.networking.remove_router_interfaces(
          @router.id, attached_subnet_ids
        )
        if @router.destroy
          @success = true
          audit_logger.info(current_user, 'has deleted', @router)
          flash.now[:notice] = 'Router successfully deleted.'
        else
          flash.now[:error] = @router.errors.full_messages.to_sentence
        end
      end

      respond_to do |format|
        format.js {}
        format.html { redirect_to routers_path }
      end
    end

    protected

    def allowed_networks
      # only cloud admin can cross-assign interfaces
      if current_user.is_allowed?('cloud_network_admin')
        services.networking.networks
      else
        services.networking.project_networks(@scoped_project_id)
      end
    end

    def fill_available_networks
      return if @external_networks && @internal_subnets

      @external_networks = []
      @internal_subnets  = []

      allowed_networks.each do |network|
        if network.external?
          @external_networks << network
        # FIXME: shared networks are not permitted for non cloud admin
        # this is a neutron bug https://bugs.launchpad.net/neutron/+bug/1662477
        # should be just 'else'
        else
          network.subnet_objects.each do |subnet|
            subnet.network_name = network.name
            @internal_subnets << subnet
          end
        end
      end
    end
  end
end
