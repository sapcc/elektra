# frozen_string_literal: true

module Compute
  # Implements Server actions
  class InstancesController < Compute::ApplicationController
    before_action :all_projects
    before_action :automation_data, only: %i[new create]

    authorization_context 'compute'
    authorization_required except: %i[new_floatingip attach_floatingip
                                      detach_floatingip remove_floatingip
                                      attach_interface create_interface
                                      remove_interface detach_interface
                                      detach_floatingip new_snapshot update_item new_size
                                      automation_script new_status]

    def index
      per_page = params[:per_page] || 20
      @instances = []


      if @scoped_project_id
        @instances = paginatable(per_page: per_page) do |pagination_options|
          services.compute.servers(@admin_option.merge(pagination_options))
        end

        # get/calculate quota data for non-admin view
        unless @all_projects
          usage = services.compute.usage

          @quota_data = []
          if current_user.is_allowed?("access_to_project")
            @quota_data = services.resource_management.quota_data(
              current_user.domain_id || current_user.project_domain_id,
              current_user.project_id,
              [
                { service_type: :compute, resource_name: :instances, usage: usage.instances },
                { service_type: :compute, resource_name: :cores, usage: usage.cores },
                { service_type: :compute, resource_name: :ram, usage: usage.ram }
              ]
            )
          end
        end
      end

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if request.xhr?
        render partial: 'list', locals: { instances: @instances }
      else
        # comon case, render index page with layout
        render action: :index
      end
    end

    def console
      @instance = services.compute.find_server(params[:id])
      hypervisor = @instance.attributes['OS-EXT-SRV-ATTR:host'] || ''
      if hypervisor.to_s.include?('nova-compute-ironic')
        @console = services.compute.remote_console(params[:id], "serial", "shellinabox")
      else
        @console = services.compute.remote_console(params[:id])
      end
      respond_to do |format|
        format.html { render action: :console, layout: 'compute/console'}
        format.json { render json: { url: @console.url }}
      end
    end

    def show
      @instance = services.compute.find_server(params[:id])
      return if @instance.blank?

      @instance_security_groups = @instance.security_groups_details
                                           .each_with_object({}) do |sg, map|
        next if map[sg.id]
        map[sg.id] = services.networking.security_groups(
          tenant_id: @scoped_project_id, id: sg.id
        ).first
      end.values

      @log = begin 
        services.compute.console_log(params[:id])
      rescue 
        nil
      end  
    end

    def new
      # get usage from db
      @quota_data = []
      if current_user.is_allowed?("access_to_project")
        @quota_data = services.resource_management.quota_data(
          current_user.domain_id || current_user.project_domain_id,
          current_user.project_id,[
          {service_type: :compute, resource_name: :instances},
          {service_type: :compute, resource_name: :cores},
          {service_type: :compute, resource_name: :ram}
        ])
      end

      @instance       = services.compute.new_server
      @flavors        = services.compute.flavors
      @images         = services.image.all_images
      @fixed_ip_ports = services.networking.fixed_ip_ports
      @subnets        = services.networking.subnets

      if params[:image_id]
        # preselect image_id
        image = @images.find { |i| i.id == params[:image_id] }
        @instance.image_id = image.id if image
      end

      azs = services.compute.availability_zones
      if azs
        @availability_zones = azs.select { |az| az.zoneState['available'] }
        @availability_zones.sort_by!(&:zoneName).reverse!
      else
        @instance.errors.add :availability_zone, 'not available'
      end

      @security_groups = services.networking.security_groups(tenant_id: @scoped_project_id)
      @private_networks = services.networking.project_networks(@scoped_project_id, "router:external"=>false) if services.networking.available?

      @keypairs = services.compute.keypairs.collect {|kp| Hashie::Mash.new({id: kp.name, name: kp.name})}

      @instance.errors.add :private_network,  'not available' if @private_networks.blank?
      @instance.errors.add :image,            'not available' if @images.blank?

      # @instance.flavor_id             = @flavors.first.try(:id)
      # @instance.image_id              = params[:image_id] || @images.first.try(:id)
      @instance.availability_zone_id    = @availability_zones.first.try(:id)
      #@instance.network_ids            = [{ id: @private_networks.first.try(:id) }]
      @instance.security_groups         = [@security_groups.find { |sg| sg.name == 'default' }.try(:id)] if @instance.security_groups.blank? # if no security group has been selected force select the default group
      @instance.keypair_id              = @keypairs.first['name'] unless @keypairs.blank?

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
      #params[:server][:security_groups] = params[:server][:security_groups].delete_if{|sg| sg.empty?} unless params[:server][:security_groups].blank?

      # remove empty security groups from params
      if params[:server] && !params[:server][:security_groups].blank?
        params[:server][:security_groups] = params[:server][:security_groups].delete_if{|sg| sg.empty?}
      end

      @instance.attributes = params[@instance.model_name.param_key]

      if @instance.image_id
        @images = services.image.images
        image = @images.find { |i| i.id == @instance.image_id }
        if image
          @instance.metadata = {
            image_name: (image.name || '').truncate(255),
            image_buildnumber:  (image.buildnumber || '').truncate(255)
          }
        end
      end

      if @instance.valid? && @instance.network_ids &&
        @instance.network_ids.length.positive?

        if @instance.network_ids.first['port'].present?
          # port is presented -> pre-resereved fixed IP is selected
          # use provided port id and update security group on port
          @port = services.networking.new_port(
            security_groups: @instance.security_groups
          )
          # set id
          @port.id = @instance.network_ids.first['port']
        elsif @instance.network_ids.first['id'].present? &&
              @instance.network_ids.first['subnet_id'].present?
          # port id isn't given but networkid and subnet id are provided.
          # -> create a port with network and subnet
          @port = services.networking.new_port(
            network_id: @instance.network_ids.first['id'],
            fixed_ips: [{subnet_id: @instance.network_ids.first['subnet_id']}],
            security_groups: @instance.security_groups
          )
        end

        if @port
          # create or update port
          if @port.id || @port.save
            @instance.network_ids.first['port'] = @port.id
          else
            @port.errors.each { |k, v| @instance.errors.add(k, v) }
          end
        elsif @instance.security_groups.present?
          @security_groups = services.networking.security_groups(
            tenant_id: @scoped_project_id
          )
          @instance.security_groups = @instance.security_groups.each_with_object([]) do |sg_id, array|
            security_group = @security_groups.find { |sg| sg_id == sg.id }
            array << security_group.name if security_group
          end
        end
      end

      if @instance.errors.empty? && @instance.save
        flash.now[:notice] = 'Instance successfully created.'
        audit_logger.info(current_user, "has created", @instance)
        @instance = services.compute.find_server(@instance.id)
      else
        @port.destroy if @port && @port.id && !@port.fixed_ip_port? && params[:server][:network_ids].first['port'].blank?
        @flavors = services.compute.flavors
        # @images = services.image.images
        @availability_zones = services.compute.availability_zones
        @security_groups ||= services.networking.security_groups(
          tenant_id: @scoped_project_id
        )

        @fixed_ip_ports = services.networking.fixed_ip_ports
        @subnets = services.networking.subnets

        @private_networks = services.networking.project_networks(
          @scoped_project_id
        ).delete_if { |n| n.attributes['router:external'] == true }
        @keypairs = services.compute.keypairs.collect do |kp|
          Hashie::Mash.new({ id: kp.name, name: kp.name })
        end
        render action: :new
      end
    end

    def edit
      @instance = services.compute.find_server(params[:id])
      if @instance.blank?
        flash.now[:error] = "We couldn't retrieve the instance details. Please try again."
      end
    end

    def update
      @instance = services.compute.new_server(params[:server])
      @instance.id = params[:id]
      if @instance.save
        flash.now[:notice] = 'Server successfully updated.'
        respond_to do |format|
          format.html { redirect_to instances_url }
          format.js { render 'update.js' }
        end
      else
        render action: :edit
      end
    end

    def new_floatingip
      enforce_permissions('::networking:floating_ip_associate')
      @instance = services.compute.find_server(params[:id])
      collect_available_ips

      @floating_ip = services.networking.new_floating_ip
    end

    # attach existing floating ip to a server interface.
    def attach_floatingip
      enforce_permissions('::networking:floating_ip_associate')

      # get instance
      @instance = services.compute.find_server(params[:id])

      # first ensure that both floating ip and fixed ip have been provided
      if params[:floating_ip][:id].blank? || params[:floating_ip][:fixed_ip_address].blank?
        collect_available_ips
        @floating_ip = services.networking.new_floating_ip
        flash.now[:error] = "Please specify both a floating IP and the interface to attach to."

        render action: :new_floatingip and return
      end

      # get project ports
      ports = services.networking.ports(device_id: params[:id])
      # find port which contains the fixed ip or take the first one.

      port = ports.find do |prt|
        prt.fixed_ips.collect { |ip| ip['ip_address'] }.include?(
          params[:floating_ip][:fixed_ip_address]
        )
      end || ports.first

      # update floating ip with the new assigned interface ip
      @floating_ip = services.networking.find_floating_ip!(params[:floating_ip][:id])
      @floating_ip.port_id = port.id
      @floating_ip.fixed_ip_address = params[:floating_ip][:fixed_ip_address]

      if @floating_ip.save
        respond_to do |format|
          format.html { redirect_to instances_url }
          format.js {}
        end
      else
        collect_available_ips
        render action: :new_floatingip
      end
    end

    def remove_floatingip
      enforce_permissions('::networking:floating_ip_disassociate')
      @instance = services.compute.find_server(params[:id])
      @floating_ip = services.networking.new_floating_ip
    end

    def detach_floatingip
      enforce_permissions('::networking:floating_ip_disassociate')

      @floating_ip = services.networking.find_floating_ip(
        params[:floating_ip][:floating_ip_id]
      )

      if @floating_ip && @floating_ip.detach
        respond_to do |format|
          format.html { redirect_to instances_url }
          format.js {
            @instance = services.compute.find_server(params[:id])
          }
        end
      else
        render action: :remove_floatingip
      end
    end

    def attach_interface
      @instance = services.compute.find_server(params[:id])
      @os_interface = services.compute.new_os_interface(params[:id])
      @os_interface.fixed_ips = []
      @networks = services.networking.networks('router:external' => false)
      @security_groups = services.networking.security_groups(
        tenant_id: @scoped_project_id
      )

      @fixed_ip_ports = services.networking.fixed_ip_ports.select do |ip|
        ip.device_id.blank?
      end
      @subnets = services.networking.subnets
    end

    def create_interface
      if params[:os_interface][:security_groups].present?
        params[:os_interface][:security_groups] =
          params[:os_interface][:security_groups].delete_if(&:blank?)
      end

      @os_interface = services.compute.new_os_interface(
        params[:id], params[:os_interface]
      )

      if @os_interface.valid? && @os_interface.net_id.present?
        if @os_interface.port_id.present?
          @port = services.networking.new_port(
            security_groups: @os_interface.security_groups
          )
          @port.id = @os_interface.port_id
        elsif @os_interface.net_id.present? &&
              @os_interface.subnet_id.present?
          @port = services.networking.new_port(
            network_id: @os_interface.net_id,
            fixed_ips: [{subnet_id: @os_interface.subnet_id}],
            security_groups: @os_interface.security_groups
          )
        end

        if @port
          if @port.id || @port.save
            @os_interface.port_id = @port.id
          else
            @port.errors.each { |k, v| @os_interface.errors.add(k, v) }
          end
        end
      end

      if @os_interface.errors.empty? && @os_interface.save
        @instance = services.compute.find_server(params[:id])
        respond_to do |format|
          format.html { redirect_to instances_url }
          format.js {}
        end
      else
        @port.destroy if @port && @port.id && !@port.fixed_ip_port? && params[:os_interface][:port_id].blank?
        @networks = services.networking.networks('router:external' => false)
        @fixed_ip_ports = services.networking.fixed_ip_ports
        @subnets = services.networking.subnets
        @security_groups = services.networking.security_groups(
          tenant_id: @scoped_project_id
        )
        render action: :attach_interface
      end
    end

    def remove_interface
      @instance = services.compute.find_server(params[:id])
      @os_interface = services.compute.new_os_interface(params[:id])
      # keep only fixed ip
      @instance.addresses.each do |_network_name, ips|
        ips.keep_if { |ip| ip['OS-EXT-IPS:type'] == 'fixed'}
      end
    end

    def detach_interface
      # create a new os_interface model based on params
      @os_interface = services.compute.new_os_interface(
        params[:id], params[:os_interface]
      )

      # load all attached server interfaces
      all_server_interfaces = services.compute.server_os_interfaces(params[:id])
      # find the one which should be deleted
      interface = all_server_interfaces.find do |i|
        i.fixed_ips.first['ip_address'] == @os_interface.ip_address
      end

      success = if interface
                  # destroy
                  @os_interface.id = @os_interface.port_id = interface.port_id
                  @os_interface.destroy
                else
                  @os_interface.errors.add(:address, 'Not found.')
                  false
                end

      if success
        # load instance after deleting os interface!!!

        # try to update instance state
        timeout = 60
        sleep_time = 3
        loop do
          @instance = services.compute.find_server(params[:id])
          interfaces = @instance.addresses.values.flatten.select do |ip|
            ip['addr'] == @os_interface.ip_address
          end
          break if timeout <= 0 || interfaces.length.zero?
          timeout -= sleep_time
          sleep(sleep_time)
        end
        respond_to do |format|
          format.html { redirect_to instances_url }
          format.js {}
        end
      else
        @instance = services.compute.find_server(params[:id])
        @os_interface.ip_address = params[:os_interface][:ip_address]
        render action: :detach_interface
      end
    end

    def new_size
      @instance = services.compute.find_server(params[:id])
      @flavors  = services.compute.flavors
    end

    def resize
      @close_modal = true
      execute_instance_action('resize',params[:server][:flavor_id])
    end

    def new_status
      @instance = services.compute.find_server(params[:id])
    end

    def reset_status
      @close_modal = true
      execute_instance_action(:reset_vm_state, params[:server][:status])
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

    def lock
      execute_instance_action
    end

    def unlock
      execute_instance_action
    end

    def automation_script
      accept_header = begin
        body = JSON.parse(request.body.read)
        os_type = body.fetch('vmwareOstype', '')
        if os_type.include? "windows"
          "text/x-powershellscript"
        else
          "text/cloud-config"
        end
      rescue => exception
        Rails.logger.error "Compute-plugin: automation_script: error getting os_type: #{exception.message}"
      end
      script = services.automation.node_install_script("", {"headers" => { "Accept" => accept_header }})
      render :json => {script: script}
    end

    def automation_data
      @automation_script_action = automation_script_instances_path()
    end

    def two_factor_required?
      if action_name=='console'
        true
      else
        super
      end
    end

    def edit_securitygroups
      @instance = services.compute.find_server(params[:id])
      @instance_security_groups = @instance.security_groups_details
      @instance_security_groups_keys = []
      @instance_security_groups.each do |sg|
        @instance_security_groups_keys << sg.id
      end
      @security_groups = services.networking.security_groups(tenant_id: @scoped_project_id)
    end

    def assign_securitygroups
      @instance = services.compute.find_server(params[:id])
      @instance_security_groups = @instance.security_groups_details
      @instance_security_groups_ids = []
      @instance_security_groups.each do |sg|
        @instance_security_groups_ids << sg.id
      end

      to_be_assigned = []
      to_be_unassigned = []

      sgs = params['sgs']
      if sgs.blank?
        flash.now[:error] = "Please assign at least one security group to the server"
        @instance = services.compute.find_server(params[:id])
        @instance_security_groups = @instance.security_groups_details
        @instance_security_groups_keys = []
        @instance_security_groups.each do |sg|
          @instance_security_groups_keys << sg.id
        end
        @security_groups = services.networking.security_groups(tenant_id: @scoped_project_id)
        render action: :edit_securitygroups and return
      else
        sgs.each do |sg|
          to_be_assigned << sg unless @instance_security_groups_ids.include?(sg)
        end
        @instance_security_groups_ids.each do |sg|
          to_be_unassigned << sg unless sgs.include?(sg)
        end

        begin
          to_be_assigned.uniq.each do |sg|
            execute_instance_action('assign_security_group',sg, false)
          end

          to_be_unassigned.uniq.each do |sg|
            execute_instance_action('unassign_security_group',sg, false)
          end

          respond_to do |format|
            format.html{ redirect_to instances_url }
          end

        rescue => e
          @instance = services.compute.find_server(params[:id])
          @instance_security_groups = @instance.security_groups_details
          @instance_security_groups_keys = []
          @instance_security_groups.each do |sg|
            @instance_security_groups_keys << sg.id
          end
          @security_groups = services.networking.security_groups(tenant_id: @scoped_project_id)
          flash.now[:error] = "An error happend while assigning/unassigned security groups to the server. Error: #{e}"
          render action: :edit_securitygroups and return
        end
      end


    end

    private

    def collect_available_ips
      @grouped_fips = {}
      networks = {}
      subnets = {}
      services.networking.project_floating_ips(@scoped_project_id).each do |fip|
        if fip.fixed_ip_address.nil?
          networks[fip.floating_network_id] = services.networking.find_network(fip.floating_network_id) unless networks[fip.floating_network_id]
          net = networks[fip.floating_network_id]
          next unless net
          unless net.subnets.blank?
            net.subnets.each do |subid|
              subnets[subid] = services.networking.find_subnet(subid) unless subnets[subid]
              sub = subnets[subid]
              cidr = NetAddr::CIDR.create(sub.cidr)
              if cidr.contains?(fip.floating_ip_address)
                @grouped_fips[sub.name] ||= []
                @grouped_fips[sub.name] << fip#[fip.floating_ip_address, fip.id]
                break
              end
            end
          else
            @grouped_fips[net.name] ||= []
            @grouped_fips[net.name] << fip#[fip.floating_ip_address, fip.id]
          end
        end
      end
    end

    def execute_instance_action(action=action_name,options=nil, with_rendering=true)
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

      render template: 'compute/instances/update_item.js' if with_rendering
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

    def all_projects
      @all_projects = current_user.is_allowed?('compute:all_projects')
      @admin_option = @all_projects ? { all_tenants: 1 } : {}
    end
  end
end
