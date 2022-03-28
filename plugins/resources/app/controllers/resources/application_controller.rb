# frozen_string_literal: true

module Resources
  class ApplicationController < DashboardController
    # check also QuotaUsageController that is inherit from this controller
    before_action :prepare_data_for_view, :unless => Proc.new { 
    [
      'webconsole',
      'identity',
      'key_manager',
      'masterdata_cockpit',
      'audit',
      'reports',
      'email_service',
      'tools',
      'kubernetes',
      'automation'
    ].include?(params[:type]) }

    # Most of the machinery in this controller is there to make cross-scope
    # jumping work. For example, as a cloud resource admin, you can open the
    # view for a random domain or project (e.g. from CloudOps) by navigating to
    # the URL path:
    #
    #   /ccadmin/cloud_admin/resources/domain/current/$DOMAIN_ID
    #
    #   /ccadmin/cloud_admin/resources/project/current/$PROJECT_DOMAIN_ID/$PROJECT_ID
    #
    # As a domain admin, you can analogously navigate to the views for any
    # project in your domain:
    #
    #   /$DOMAIN_NAME/resources/project/current/$DOMAIN_ID/$PROJECT_ID
    #
    # As a cloud admin, you also used to be able to navigate to domains and
    # projects in foreign clusters by exchanging "current" for the correct
    # cluster ID. (Multi-cluster support was removed from Limes, so "current"
    # is now hardcoded in the URLs to preserve backwards compatibility.)
    #
    # The policy.json is therefore a bit more complicated than you might
    # expect, and the syntax it uses only works with the Ruby implementation of
    # the policy engine, not with the JS implementation (as far as I've
    # tested). We therefore perform all policy checks on the Rails side and
    # pass the "can_edit" flag to React to toggle between read-only and
    # read-write view.

    def project
      @scope = 'project'
      @edit_role = 'resource_admin'
      @js_data[:project_id] = params[:override_project_id] || @scoped_project_id
      @js_data[:domain_id]  = params[:override_domain_id]  || @scoped_domain_id

      auth_params = { selected: @js_data }
      enforce_permissions('::resources:project:show', auth_params)
      @js_data[:can_edit] = current_user.is_allowed?('resources:project:edit', auth_params)

      # p "======================================================"
      # # {"qa-de-1a"=>{"3.0"=>"1.5TiB, 2TiB, 3TiB"}}
      # p @js_data[:big_vm_resources]
      render action: 'show'
    end

    def init_project
      # This is the entrypoint for the "Initialize Project Resources" step in
      # the project setup wizard. Note that it can only be used with
      # `resources:project:edit` permissions.
      @js_data[:project_id] = @scoped_project_id
      @js_data[:domain_id]  = @scoped_domain_id

      auth_params = { selected: @js_data }
      enforce_permissions('::resources:project:edit', auth_params)
      @js_data[:can_edit] = true

      render action: 'init_project'
    end

    def domain
      @scope = 'domain'
      @edit_role = 'resource_admin'
      @js_data[:domain_id] = params[:override_domain_id] || @scoped_domain_id

      auth_params = { selected: @js_data }
      enforce_permissions('::resources:domain:show', auth_params)
      @js_data[:can_edit] = current_user.is_allowed?('resources:domain:edit', auth_params)

      render action: 'show'
    end

    def cluster
      @scope = 'cluster'
      @edit_role = 'cloud_resource_admin'

      auth_params = { selected: @js_data }
      enforce_permissions('::resources:cluster:show', auth_params)
      @js_data[:can_edit] = current_user.is_allowed?('resources:cluster:edit', auth_params)

      render action: 'show'
    end

    def bigvm_resources
      # render json: fetch_big_vm_data
      render json: dedicated_hana_vm_region? ? fetch_hana_big_vm_data : fetch_big_vm_data
    end

    private

    def prepare_data_for_view

      @project =  services.identity.find_project!(@scoped_project_id) 
      @js_data = {
        token:            current_user.token,
        limes_api:        current_user.service_url('resources'), # see also init.js -> configureAjaxHelper
        castellum_api:    current_user.service_url('castellum'), # see also init.js -> configureCastellumAjaxHelper
        placement_api:    current_user.service_url('placement'),
        flavor_data:      fetch_baremetal_flavor_data,
        # do not load bigvm resources on init
        # use ajax instead (see: bigvm_resources action)
        # big_vm_resources: fetch_big_vm_data,
        docs_url:         sap_url_for('documentation'),
      } # this will end in widget.config.scriptParams on JS side

      unless @project.nil?
        sharding_enabled = @project.sharding_enabled
        project_shards = @project.shards || []
        @js_data[:sharding_enabled] = sharding_enabled
        @js_data[:project_shards] = project_shards
        @js_data[:project_scope] = true
        @js_data[:path_to_enable_sharding] = plugin('identity').project_enable_sharding_path()
      else 
        # domain and ccadmin scope
        @js_data[:sharding_enabled] = false
        @js_data[:project_shards] = []
        @js_data[:project_scope] = false
        @js_data[:path_to_enable_sharding] = ""
      end

      # when this is true, the frontend will never try to generate quota requests
      @js_data[:is_foreign_scope] = (params[:override_project_id] || params[:override_domain_id]) ? true : false

      # these variables (@XXX_override) trigger an infobox at the top of the
      # view informing that the user that they're viewing a foreign scope
      if params[:override_project_id]
        @project_override = services.identity.find_project!(params[:override_project_id])
      end
      if params[:override_domain_id]
        @domain_override = services.identity.find_domain!(params[:override_domain_id])
      end
    end

    def fetch_baremetal_flavor_data
      mib = Core::DataType.new(:bytes, :mega)
      gib = Core::DataType.new(:bytes, :giga)
      result = {}

      cloud_admin.compute.flavors.each do |f|
        next unless f.name =~ /^z/

        # cache extra-specs between requests to keep rendering time down
        @@flavor_metadata_cache ||= {}
        m = (@@flavor_metadata_cache[f.id] ||=
          cloud_admin.compute.find_flavor_metadata(f.id))
        next if m.nil?

        primary = []
        primary << "#{f.vcpus} cores" if f.vcpus
        primary << "#{mib.format(f.ram.to_i)} RAM" if f.ram
        primary << "#{gib.format(f.disk.to_i)} disk" if f.disk
        result[f.name] = {
          primary: primary,
          secondary: m.attributes['catalog:description'] || '',
        }
      end
      return result
    end

    # A region that has flavors with the trait CUSTOM_HANA_EXCLUSIVE_HOST='required' 
    # can mount dedicated hana vms.
    def dedicated_hana_vm_region?
      @flavors = @flavors || cloud_admin.compute.flavors
      @flavors.select do |f|
        f.extra_specs.select {|key,value| key == "trait:CUSTOM_HANA_EXCLUSIVE_HOST" && value == "required"}.length > 0 &&
        f.name.starts_with?("hana_")
      end.length > 0
    end


    # dedicated Hana VM BBs in CCloud
    # !!!It's crazy to implement that inUI, but the backend guys don't want to give us that via API.!!!
    # 1. Check for 
    #    CUSTOM_HANA_EXCLUSIVE_HOST traits and CUSTOM_NUMASIZE_C48_M729 or CUSTOM_NUMASIZE_C48_M1459
    #    openstack resource provider list --required CUSTOM_HANA_EXCLUSIVE_HOST --required CUSTOM_NUMASIZE_C48_M729
    #    openstack resource provider list --required CUSTOM_HANA_EXCLUSIVE_HOST --required CUSTOM_NUMASIZE_C48_M1459
    # 2. Check the size of the BB (3Tb or 6TB)
    #    openstack resource provider inventory list 2ea46894-6a93-4b05-a91b-b03044b28a4e
    #    the inventory contains a max_unit column which, for the MEMORY_MB resource_class, shows the HV size
    # 3. Check the free space on the BB
    #    openstack resource provider inventory list 2ea46894-6a93-4b05-a91b-b03044b28a4e
    #    MEMORY_MB: (total -reserved) * allocation_ration – used = free capacity – the Hana flavors to find out which would still fit.
    #    used = (openstack resource provider usage show <RP_UUID>)['MEMORY_MB']      
    # 4. Translate the resource-provider uuid to a BB by looking at Nova's API for the hypervisors:
    #    nova hypervisor-show 2ea46894-6a93-4b05-a91b-b03044b28a4e 
    #    to get the service_host
    # 5. Show the Flavors which would fit.
    def fetch_hana_big_vm_data
      hana_trait = 'CUSTOM_HANA_EXCLUSIVE_HOST'
      custom_traits = ["CUSTOM_NUMASIZE_C48_M729","CUSTOM_NUMASIZE_C48_M1459"]
      
      # get flavors with NUMASIZE trait
      @flavors = @flavors || cloud_admin.compute.flavors
      relevant_flavors = @flavors.select do |f|
        f.extra_specs.select {|key,value| key == "trait:#{hana_trait}" && value == "required"}.length > 0 &&
        f.name.starts_with?("hana_")
      end

      # return unless region supports NUMASIZE flavors
      return [] if relevant_flavors.empty?

      # group flavors by trait
      # { trait => flavors }
      flavors_by_numa = relevant_flavors.each_with_object({}) do |flavor, hash| 
        custom_traits.each do |trait| 
          if flavor.extra_specs.has_key?("trait:#{trait}")
            hash[trait] ||= []
            hash[trait] << flavor
          end
        end
        hash
      end

      # build a map for host -> AZ, e.g. nova-compute-bb92: qa-de-1a
      # build a map for host -> VC (shards), e.g. nova-compute-bb92: vc-a-0
      host_az_map = {}
      host_vc_map = {}

      # fetch availability zones and shards
      cloud_admin.compute.host_aggregates.each do |ha|
        # ignore this aggregate unless availability_zone or hosts are present
        next if ha.availability_zone.nil? || ha.hosts.nil?  
 
        ha.hosts.each do |hostname|
          if ha.availability_zone == ha.name
            host_az_map[hostname] =  ha.availability_zone
          elsif ha.name.starts_with?('vc-')
            host_vc_map[hostname] = ha.name
          end
        end
      end

      project_shards = @project ? @project.shards : []

      # add all shards to project shards if sharding is enabled 
      if @project && @project.sharding_enabled 
        project_shards = host_vc_map.values.uniq
      end

      result = []
      # for all traits do
      custom_traits.each do |trait|
        bigvm_resource_providers = cloud_admin.resources.list_resource_providers({
          required: "#{hana_trait},#{trait}"
        }).uniq {|rp| rp["uuid"]}

        bigvm_resource_providers.each do |rp|
          # get host from hypervisor
          host = cloud_admin.compute.find_hypervisor(rp['uuid']).try(:host)
          # host = hypervisor && hypervisor.host

          # map the shards to the related host
          shard = host_vc_map[host]
          if shard && project_shards.include?(host_vc_map[host])
            rp['shard'] = shard
          end

          next unless host
          # map and filter the availability_zone to the host
          # only availability_zones are allowed that are related to the shards 
          # that are available for the project
          # in case project_shards.empty? any resource_provider_name is allowed
          if rp['shard'] || project_shards.empty?
            rp['az'] = host_az_map[host]
          end

          # ignore this resource provider unless availability_zone is present
          next unless rp['az'] 

          inventories = cloud_admin.resources.get_resource_provider_inventory(rp['uuid'])
          usages = cloud_admin.resources.get_resource_provider_usage(rp['uuid'])
        
          memory = inventories.fetch('MEMORY_MB',{})
          host_mb = memory.fetch('max_unit')
          total = memory.fetch('total')
          reserved = memory.fetch('reserved')
          allocation_ratio = memory.fetch('allocation_ratio')
          used = usages.fetch('MEMORY_MB',0)
          free = (total - reserved) * allocation_ratio - used
  
          if host_mb.blank?
            # should not happen. broken nova-compute
            raise "could not find host memory of #{rp['uuid']}"
          end
          possible_flavors = flavors_by_numa[trait].select {|f| f.ram <= free}         

          result << {
            az: rp['az'],
            shard: rp['shard'],
            name: rp['name'],
            size_mb: host_mb, # get the parent for every bigvm rp
            numa_trait: trait,
            status: possible_flavors.length > 0 ? "free" : "used",
            flavors: possible_flavors.map {|f| {
              name: f.name, 
              disk: f.disk,
              vcpus: f.vcpus,
              ram: f.ram,
            }}
          }
        end
      end
      return result
    end

    # fetches all bigvms taking into account the availability zone, project shards 
    # and provider traits
    def fetch_big_vm_data
      # get flavors with NUMASIZE trait
      @flavors = @flavors || cloud_admin.compute.flavors
      
      relevant_flavors = @flavors.select do |f|
        f.extra_specs.keys.find {|k| /trait:CUSTOM_NUMASIZE_/ =~ k}
      end
      # return unless region supports NUMASIZE flavors
      return [] if relevant_flavors.empty?
      flavors_by_numa = {}
    
      # group flavors by trait
      # { trait => flavors }
      relevant_flavors.each do |f|
        trait = f.extra_specs.keys.find {|k| /trait:CUSTOM_NUMASIZE_/ =~ k}
        next if trait.blank? 
        trait_key = trait.gsub('trait:CUSTOM_NUMASIZE_','')

        flavors_by_numa[trait_key] ||= []
        flavors_by_numa[trait_key] << f
      end

      project_shards = @project ? @project.shards : []

      # filter bigvms by specific name prefix
      bigvm_resource_providers = cloud_admin.resources.list_resource_providers.select do |rp| 
        rp["name"].starts_with?("bigvm-deployment-")
      end

      # build a map for host -> AZ, e.g. nova-compute-bb92: qa-de-1a
      # build a map for host -> VC (shards), e.g. nova-compute-bb92: vc-a-0
      host_az_map = {}
      host_vc_map = {}

      # fetch availability zones and shards
      cloud_admin.compute.host_aggregates.each do |ha|
        # ignore this aggregate unless availability_zone or hosts are present
        next if ha.availability_zone.nil? || ha.hosts.nil?  

        ha.hosts.each do |hostname|
          if ha.availability_zone == ha.name
            host_az_map[hostname] =  ha.availability_zone
          elsif ha.name.starts_with?('vc-')
            host_vc_map[hostname] = ha.name
          end
        end
      end

      # add all shards to project shards if sharding is enabled 
      if @project && @project.sharding_enabled 
        project_shards = host_vc_map.values.uniq
      end

      bigvm_rps = []

      # set the AZ and VC for every bigvm rp
      bigvm_resource_providers.each do |rp|
        host = rp['name'].gsub('bigvm-deployment-','')
        rp['host'] = host

        # map the shards to the related host
        shard = host_vc_map[host]
        if shard && project_shards.include?(host_vc_map[host])
          rp['shard'] = shard
        end

        # map and filter the availability_zone to the host
        # only availability_zones are allowed that are related to the shards 
        # that are available for the project
        # in case project_shards.empty? any resource_provider_name is allowed
        if rp['shard'] || project_shards.empty?
          rp['az'] = host_az_map[host]
        end

        # ignore this resource provider unless availability_zone is present
        next unless rp['az'] 

        # get the usage of current resource provider
        inventories = cloud_admin.resources.get_resource_provider_inventory(rp['uuid'])
        reserved = inventories.fetch('CUSTOM_BIGVM',{}).fetch('reserved',nil)
        if reserved.blank? 
          rp['status'] = 'waiting'
        elsif reserved == 1
          rp['status'] = 'used'
        elsif reserved == 0
          rp['status'] = 'free'
        else
          rp['status'] = 'unknown'
        end

        # fetch the parent uuid of thi rp unless set
        if rp['parent_provider_uuid'].blank? 
          puts "Info: no parent_provider_uuid was found, try to get it from aggregates"
          rp_aggregates = cloud_admin.resources.get_resource_provider_aggregates(rp['uuid'])
          rp['parent_provider_uuid'] = rp_aggregates[0] unless rp_aggregates.empty?
        end

        # get the host_size for current rp
        parent_inventories = cloud_admin.resources.get_resource_provider_inventory(rp['parent_provider_uuid'])
        host_mb = parent_inventories.fetch('MEMORY_MB', {}).fetch('max_unit')
        if host_mb.blank?
          # should not happen. broken nova-compute
          raise "could not find host memory of #{rp['uuid']}"
        end
        rp['host_size_mb'] = host_mb# get the parent for every bigvm rp


        # get the traits for current rp to show NUMA
        traits = cloud_admin.resources.traits(rp['parent_provider_uuid']).select do |t|
          t.starts_with? 'CUSTOM_NUMASIZE_'
        end.map {|t| t.gsub('CUSTOM_NUMASIZE_','')}

        rp['numa_trait'] = traits
        bigvm_rps << rp
      end
      
      # collect all resource providers which have the availability zone
      result = []
      bigvm_rps.each do |rp|
        # p "#{rp['host']} #{rp['az']} #{rp['shard']} #{rp['numa_trait']}"
        next unless rp['az']
        
        flavors = []
        rp['numa_trait'].each {|numa| flavors.concat(flavors_by_numa[numa])}
        flavors.select! {|f| f.ram <= rp['host_size_mb']}
        flavors = flavors.uniq{|f| f.name}
        next if flavors.empty?

        result << {
          az: rp['az'],
          shard: rp['shard'],
          name: rp['host'], 
          size_mb: rp['host_size_mb'], 
          numa_trait: rp['numa_trait'], 
          status: rp['status'],
          flavors: flavors.map{|f| {
            name: f.name, 
            disk: f.disk,
            vcpus: f.vcpus,
            ram: f.ram,
          }}
        }
      end
      result
    end
  end
end
