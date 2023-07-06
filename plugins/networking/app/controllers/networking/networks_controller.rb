# frozen_string_literal: true

module Networking
  # Implements Network actions
  class NetworksController < DashboardController
    before_action :load_type, except: %i[ip_availability manage_subnets]

    def index
      @preview = params[:preview] == "true"
      @networks = cached_networks

      # load live data if preview param not set
      unless @preview
        filter_options = {
          "router:external" => @network_type == "external",
          :sort_key => "name",
        }
        begin          
          live_networks =
          paginatable(per_page: 30) do |pagination_options|
            options = filter_options.merge(pagination_options)
            unless current_user.has_role?("cloud_network_admin")
              options.delete(:limit)
            end
            services.networking.networks(options)            
          end

          # merge the live networks with the cached networks mapping by id
          # this is due to the fact that the live networks are incomplete when using limit
          new_neworks = []
          groups = (live_networks + cached_networks).group_by(&:id)
          groups.flat_map do |_id, items|
            if items.length > 1
              # save the item from live data (not cached)
              merged_item = items.find {|e| !e.local_cache }
              new_neworks << merged_item
            else
              new_neworks << items.first
            end              
          end

          @networks = new_neworks
        rescue ::Elektron::Errors::Request => exception
          flash.now[:error] = "Error while fetching networks: #{exception.message}"
          # if timeout loading data still display the cached networks
          @timeout = true #disable reload with live data if error occurs
          @preview = true
        end 
      end

      @network_subnets =
        @networks.each_with_object({}) do |nw, map|
          map[nw.id] = services.networking.subnets(network_id: nw.id)
        end

      @network_projects =
        ObjectCache
          .where(id: @networks.collect(&:tenant_id))
          .each_with_object({}) { |project, map| map[project.id] = project }

      # enable pagination just for live data after the table is rendered without cached data
      if !@preview && request.xhr? && (params[:page] || params[:marker])
        # this is relevant in case an ajax paginate call is made.
        # in this case we don't render the layout, only the list!
        render partial: "list", locals: { networks: @networks, preview: @preview }
      end
    end


    def manage_subnets
      @network = services.networking.find_network(params[:network_id])
    end

    def show
      @network = services.networking.find_network!(params[:id])
      @subnets = services.networking.subnets(network_id: @network.id)
      @ports = services.networking.ports(network_id: @network.id)
    end

    def new
      @network =
        services.networking.new_network(
          name: "#{@scoped_project_name}_#{@network_type}",
        )
      @subnet =
        services.networking.new_subnet(
          name: "#{@network.name}_sub",
          enable_dhcp: true,
        )
    end

    def create
      network_params = params[:network]
      subnets_params = network_params.delete(:subnets)
      @network = services.networking.new_network(network_params)
      @errors = []

      if @network.save
        if subnets_params.present?
          @subnet = services.networking.new_subnet(subnets_params)
          @subnet.network_id = @network.id

          # FIXME: anti-pattern of doing two things in one action
          if @subnet.save
            flash[
              :keep_notice_htmlsafe
            ] = "Network #{@network.name} with subnet #{@subnet.name} successfully created.<br /> <strong>Please note:</strong> If you want to attach floating IPs to objects in this network you will need to #{view_context.link_to("create a router", plugin("networking").routers_path)} connecting this network to the floating IP network."
            audit_logger.info(current_user, "has created", @network)
            audit_logger.info(current_user, "has created", @subnet)
            redirect_to plugin("networking").send(
                          "networks_#{@network_type}_index_path",
                        )
          else
            @network.destroy
            @errors = @subnet.errors
            render action: :new
          end
        else
          audit_logger.info(current_user, "has created", @network)
          redirect_to plugin("networking").send(
                        "networks_#{@network_type}_index_path",
                      )
        end
      else
        @errors = @network.errors
        render action: :new
      end
    end

    def edit
      @action_from_show = params[:action_from_show] || "false"
      @network = services.networking.find_network(params[:id])
    end

    def update
      @action_from_show =
        params[:network].delete(:action_from_show) == "true" || false
      @network = services.networking.new_network(params[:network])
      @network.id = params[:id]

      if @network.save
        flash[:notice] = "Network successfully updated."
        audit_logger.info(current_user, "has updated", @network)
        if @action_from_show
          redirect_to plugin("networking").send(
                        "networks_#{@network_type}_path",
                        @network.id,
                      )
        else
          redirect_to plugin("networking").send(
                        "networks_#{@network_type}_index_path",
                      )
        end
      else
        render action: :edit
      end
    end

    def destroy
      @action_from_show = params[:action_from_show] == "true" || false
      @network = services.networking.new_network
      @network.id = params[:id]

      if @network
        if @network.destroy
          audit_logger.info(current_user, "has deleted", @network)
          flash[:notice] = "Network successfully deleted."
        else
          flash[:error] = @network.errors.full_messages.to_sentence
        end
      end

      respond_to do |format|
        format.js {}
        format.html do
          redirect_to plugin("networking").send(
                        "networks_#{@network_type}_index_path",
                      )
        end
      end
    end

    def ip_availability
      availability =
        begin
          # you need to be network_viewer or network_admin in the project the network is defined in.
          # since the floating ip networks are usually shared from other projects we need to use the cloud_admin user.
          cloud_admin.networking.network_ip_availability(params[:network_id])
        rescue StandardError
          nil
        end

      render json: availability.nil? ? [] : availability.subnet_ip_availability
    end

    private

    def load_type
      raise "has to be implemented in subclass"
    end

    def cached_networks
      begin 
        all_networks = ObjectCache.find_objects(type: "network", include_scope: true) {
          |scope| scope.where("project_id = ?", (current_user.project_id).to_s)
        }
        # extract networks with type external and tag object as local_cache
        type_network = all_networks.each_with_object([]) do |cached_network, networks|
          payload = cached_network.payload
          payload[:local_cache] = true
          if payload["router:external"] == (@network_type == "external")
            networks << Networking::Network.new(nil, payload)
          end
        end

        # find all rbacs with target_tenant = "*" (all projects) or target_tenant = current project and object_type network
        domain_id = current_user.domain_id || current_user.project_domain_id
        temp_rbacs = ObjectCache.find_objects(type: "rbac_policy", include_scope: true) {
          |scope| scope.where("(payload->>'target_tenant' = ? OR payload->>'target_tenant' = ?) AND payload->>'object_type' = ?", "*", current_user.project_id.to_s, "network")
          # |scope| scope.where("(payload->>'target_tenant' = ? OR payload->>'target_tenant' = ?) AND payload->>'object_type' = ? AND payload->>'domain_id' = ?", "*", current_user.project_id, "network", domain_id)
        }      
        # get just rbacs from the same domain
        external_shared_networks_ids = temp_rbacs.each_with_object([]) do |cached_rbac, rbacs|
          scope = cached_rbac["payload"].fetch("scope", {})
          rbacs <<cached_rbac["payload"]["object_id"] if scope["domain_id"] == domain_id
        end

        # find all shared networks
        shared_networks = external_shared_networks_ids.each_with_object([]) do |id, array|        
          # find all networks with id from rbacs and network type
          objects = ObjectCache.find_objects(type: "network", term: id) {          
            |scope| scope.where("payload->>'id' = ? AND payload->>'router:external'= ?", id, (@network_type == "external").to_s)
          }
          # the shared flag is calculated by the server based on the calling project and the RBAC entries for each network
          # that means that the flag of the shared object in cache is being overwritten depending from which project is being called.
          if objects.length == 1
            net = objects.first
            net.payload[:local_cache] = true
            net.payload[:shared] = true
            array <<  Networking::Network.new(nil, net.payload)
          end
        end

        # remove duplicates
        total_neworks = []
        groups = (type_network + shared_networks).group_by(&:id)
        groups.flat_map do |_id, items|
          if items.length > 1
            # if a network exists in netowrks and in shared networks means that the project is the owner of the network and should not be displayed as shared
            net = items.first
            net.shared = false
            total_neworks << net
          else 
            total_neworks << items.first
          end        
        end

        # sort total_neworks by attribute name
        total_neworks.sort_by!(&:name)
      rescue StandardError
        []
      end
    end

  end
end
