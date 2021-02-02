# frozen_string_literal: true

module Resources
  class ApplicationController < DashboardController
    before_action :prepare_data_for_view

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
    # As a cloud admin, you can even navigate to domains and projects in
    # foreign clusters by exchanging "current" for the correct cluster ID.
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

    private

    def prepare_data_for_view
      
      @js_data = {
        token:            current_user.token,
        limes_api:        current_user.service_url('resources'), # see also init.js -> configureAjaxHelper
        castellum_api:    current_user.service_url('castellum'), # see also init.js -> configureCastellumAjaxHelper
        placement_api:    current_user.service_url('placement'),
        flavor_data:      fetch_baremetal_flavor_data,
        big_vm_resources: fetch_big_vm_data,
        docs_url:         sap_url_for('documentation'),
        cluster_id:       params[:cluster_id] || 'current',
      } # this will end in widget.config.scriptParams on JS side

      @project =  services.identity.find_project!(@scoped_project_id) 
      unless @project.nil?
        sharding_enabled = @project.sharding_enabled
        project_shards = @project.shards || []
        @js_data[:sharding_enabled] = sharding_enabled
        @js_data[:project_shards] = project_shards
        @js_data[:project_scope] = true
      else 
        # domain and ccadmin scope
        @js_data[:sharding_enabled] = false
        @js_data[:project_shards] = []
        @js_data[:project_scope] = false
      end

      # when this is true, the frontend will never try to generate quota requests
      @js_data[:is_foreign_scope] = (params[:override_project_id] || params[:override_domain_id] || (@js_data[:cluster_id] != 'current')) ? true : false

      # these variables (@XXX_override) trigger an infobox at the top of the
      # view informing that the user that they're viewing a foreign scope
      if @js_data[:cluster_id] == 'current'
        if params[:override_project_id]
          @project_override = services.identity.find_project!(params[:override_project_id])
        end
        if params[:override_domain_id]
          @domain_override = services.identity.find_domain!(params[:override_domain_id])
        end
      else
        @cluster_override = @js_data[:cluster_id]
        if params[:override_project_id]
          @project_override = Identity::Project.new(nil, { name: params[:override_project_id] })
        end
        if params[:override_domain_id]
          @domain_override = Identity::Domain.new(nil, { name: params[:override_domain_id] })
        end
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

    def fetch_big_vm_data

      big_vm_resources = {}
      resource_providers = cloud_admin.resources.list_resource_providers
      
      # domain level: we do not show bigVMresources
      if @project.nil?
        return {}
      end
      project_shards = @project.shards
 
      # build mapping between AV(availability_zone) or VZ(shard) and host_aggregates.name
      host_aggregates = cloud_admin.compute.host_aggregates
      hosts_az = {}
      hosts_shard = {}
      unless host_aggregates.nil?
        host_aggregates.each do |host_aggregate|
          #pp host_aggregate
          unless host_aggregate.hosts.nil?
            host_aggregate.hosts.each do |hostname|
              if host_aggregate.name == host_aggregate.availability_zone
                # this is a availability_zone
                hosts_az[hostname] = host_aggregate.name
              else
                # this is a shard
                hosts_shard[hostname] = host_aggregate.name
              end
            end
          end
        end
      end

      #puts "HOSTS_SHARDS"
      #pp hosts_shard
      #{
      #  "nova-compute-bb95"=>"vc-a-1",
      #  "nova-compute-bb93"=>"vc-b-0",
      #  "nova-compute-bb94"=>"vc-b-0",
      #  "nova-compute-bb91"=>"vc-a-0",
      #  "nova-compute-bb92"=>"vc-a-0"
      #}

      #puts "HOSTS_AZ"
      #pp hosts_az
      #{
      #  "nova-compute-bb91"=>"qa-de-1a",
      #  "nova-compute-bb92"=>"qa-de-1a",
      #  "nova-compute-ironic-bm092"=>"qa-de-1a",
      #  "nova-compute-bb95"=>"qa-de-1a",
      #  "nova-compute-bb93"=>"qa-de-1b",
      #  "nova-compute-bb94"=>"qa-de-1b",
      #  "nova-compute-ironic-bm091"=>"qa-de-1b"
      #}

      resource_providers.each do |resource_provider|
        # filter only for resource_providers with name "bigvm-deployment-"
        if resource_provider["name"].include? "bigvm-deployment-"
          # get hostname like nova-compute-bb91
          resource_provider_name = resource_provider["name"].gsub("bigvm-deployment-","")
          
          # create empty resource_provider config
          big_vm_resources[resource_provider_name] = {}

          # map the shards to the related resource_provider_name
          # "nova-compute-bb91"=>"vc-a-0"
          hosts_shard.keys.each do |hostname|
            shard = hosts_shard[hostname]
            if project_shards.include?(shard) && resource_provider_name == hostname
              # shards for projects are defined so we filter only resource_provider that are related to the shard
              big_vm_resources[resource_provider_name]["shard"] = shard
            end
          end

          # map and filter the availability_zone to the resource_provider_name
          # "nova-compute-bb91"=>"qa-de-1a"
          hosts_az.keys.each do |hostname|
            # only availability_zones are allowed that are related to the shards that are available for the project
            # in case project_shards.empty? any resource_provider_name is allowed
            if resource_provider_name == hostname && ( big_vm_resources[resource_provider_name]["shard"] || project_shards.empty? )
              availability_zone = hosts_az[hostname]
              #puts "MAPPING"
              #puts hostname
              #puts resource_provider_name 
              #puts availability_zone 
              big_vm_resources[resource_provider_name]["availability_zone"] = availability_zone
            end
          end

          # filter resource_provider config if no availability_zone was found
          # this should be the case if the availability_zone was filtered 
          unless big_vm_resources[resource_provider_name]["availability_zone"] 
            big_vm_resources.delete(resource_provider_name)
            next
          end

          parent_provider_uuid   = resource_provider["parent_provider_uuid"]
          resource_provider_uuid = resource_provider["uuid"]
          resource_links         = resource_provider["links"]
          
          #puts "RESOURCE PROVIDER"
          #pp resource_provider
          # https://github.com/sapcc/helm-charts/blob/master/openstack/sap-seeds/templates/flavor-seed.yaml
          # see host_fraction
          # available HVs 1.5Tib, 2TiB, 3TiB, 6TiB
          # bigvm-size : allowed_hv_size
          big_vm_sizes = {
            "1.5":[1.5,2,3],
            "2":  [2,3],
            "3":  [3,6],
            "4":  [6],
            "6":  [6],
          }
          resource_links.each do |resource_link|
            available = false
            if resource_link["rel"] == "inventories"
              # check that hypervisors for big vms are available
              available = cloud_admin.resources.big_vm_available(resource_provider_uuid)
              if available == true
                inventory_data = cloud_admin.resources.get_resource_provider_inventory(parent_provider_uuid)
                if inventory_data && inventory_data.key?("MEMORY_MB")
                  memory_size_in_mb =  inventory_data["MEMORY_MB"]["max_unit"] || 0
                  big_vm_resources[resource_provider_name]["memory"] = sprintf("%.1f",memory_size_in_mb.to_f/1000/1000).to_s
                  # big_vm_resources[resource_provider_name]["memory"] = "6"
                  
                  # calculate available bigvms
                  big_vm_resources[resource_provider_name]["available_big_sizes"] = ""
                  big_vm_sizes.each do |size ,allowed_hv_size|
                    allowed_hv_size.each do |hv_size|
                      if hv_size.to_f == big_vm_resources[resource_provider_name]["memory"].to_f
                        big_vm_resources[resource_provider_name]["available_big_sizes"] += "#{size}TiB, "
                        break
                      end
                    end
                  end

                  unless big_vm_resources[resource_provider_name]["available_big_sizes"].empty?
                    big_vm_resources[resource_provider_name]["available_big_sizes"].chomp!(", ")
                  else
                    big_vm_resources[resource_provider_name]["available_big_sizes"] = "??? Unkown HV size ???"
                  end

                  # puts "MEMORY_MB"
                  # puts resource_provider_name
                  # puts inventory_data["MEMORY_MB"]["max_unit"]
                  # puts big_vm_resources[resource_provider_name]
                else
                  big_vm_resources.delete(resource_provider_name)
                  next
                end
              else
                big_vm_resources.delete(resource_provider_name)
                next
              end
            end
          end
        end
      end

      #puts "BIG_VM_RESOURCES"
      #pp big_vm_resources
      #big_vm_resources = {"nova-compute-bb124"=>
      #  {"availability_zone"=>"qa-de-1a",
      #   "memory"=>"2.0",
      #   "available_big_sizes"=>"2x1TiB, 1x1.5TiB, 1x2TiB"},
      # "nova-compute-bb137"=>
      #  {"availability_zone"=>"qa-de-1b",
      #   "memory"=>"2.0",
      #   "available_big_sizes"=>"2x1TiB, 1x1.5TiB, 1x2TiB"},
      # "nova-compute-bb45"=>
      #  {"availability_zone"=>"qa-de-1b",
      #   "memory"=>"1.5",
      #   "available_big_sizes"=>"1x1TiB, 1x1.5TiB"}}

      # massage data for better use
      big_vms_by_az = {}
      big_vm_resources.each do |key,value|
        if value.key? "memory"
          big_vms_by_az[value["availability_zone"]] ||= {} 
          # there is only one HV per az and memory size
          big_vms_by_az[value["availability_zone"]][value["memory"]] = value["available_big_sizes"]
        end
      end

      #fake data for debug
      #puts "BIG_VM_BY_AZ"
      #pp big_vms_by_az
      #big_vms_by_az["qa-de-1a"]["6"] = "BB-bla"
      #big_vms_by_az["qa-de-1b"]["6"] = "BB-bla"
      #big_vms_by_az["qa-de-1b"]["3"] = "BB-bla"

      return big_vms_by_az
    end

  end
end
