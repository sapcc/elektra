# frozen_string_literal: true

module Resources
  class ApplicationController < DashboardController
    # check also QuotaUsageController that is inherit from this controller
    before_action :prepare_data_for_view,
                  unless:
                    Proc.new {
                      %w[
                        webconsole
                        identity
                        key_manager
                        masterdata_cockpit
                        audit
                        reports
                        email_service
                        tools
                        kubernetes
                        automation
                      ].include?(params[:type])
                    }

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
      @scope = "project"
      @edit_role = "resource_admin"
      @js_data[:project_id] = params[:override_project_id] || @scoped_project_id
      @js_data[:domain_id] = params[:override_domain_id] || @scoped_domain_id

      auth_params = { selected: @js_data }
      enforce_permissions("::resources:project:show", auth_params)
      @js_data[:can_edit] = current_user.is_allowed?(
        "resources:project:edit",
        auth_params,
      )
      @js_data[:can_edit_c_q_d] = current_user.is_allowed?(
        "resources:cluster:edit",
        auth_params,
      ) # project quota for CQD resources can only be adjusted by cloud admins
      @js_data[:can_goto_cluster] = current_user.is_allowed?(
        "resources:project:goto_cluster",
        auth_params,
      )

      # p "======================================================"
      # # {"qa-de-1a"=>{"3.0"=>"1.5TiB, 2TiB, 3TiB"}}
      # p @js_data[:big_vm_resources]
      render action: "show"
    end

    def init_project
      # This is the entrypoint for the "Initialize Project Resources" step in
      # the project setup wizard. Note that it can only be used with
      # `resources:project:edit` permissions.
      @js_data[:project_id] = @scoped_project_id
      @js_data[:domain_id] = @scoped_domain_id

      auth_params = { selected: @js_data }
      enforce_permissions("::resources:project:edit", auth_params)
      @js_data[:can_edit] = true

      render action: "init_project"
    end

    def domain
      @scope = "domain"
      @edit_role = "resource_admin"
      @js_data[:domain_id] = params[:override_domain_id] || @scoped_domain_id

      auth_params = { selected: @js_data }
      enforce_permissions("::resources:domain:show", auth_params)
      @js_data[:can_edit] = current_user.is_allowed?(
        "resources:domain:edit",
        auth_params,
      )
      @js_data[:can_edit_c_q_d] = current_user.is_allowed?(
        "resources:cluster:edit",
        auth_params,
      ) # project quota for CQD resources can only be adjusted by cloud admins
      @js_data[:can_goto_cluster] = current_user.is_allowed?(
        "resources:domain:goto_cluster",
        auth_params,
      )

      render action: "show"
    end

    def cluster
      @scope = "cluster"
      @edit_role = "cloud_resource_admin"

      auth_params = { selected: @js_data }
      enforce_permissions("::resources:cluster:show", auth_params)
      @js_data[:can_edit] = current_user.is_allowed?(
        "resources:cluster:edit",
        auth_params,
      )
      @js_data[:can_edit_c_q_d] = current_user.is_allowed?(
        "resources:cluster:edit",
        auth_params,
      ) # same as can_edit here; only needed for consistency

      render action: "show"
    end

    def bigvm_resources
      # render json: fetch_big_vm_data
      require "net/http"
      begin
        uri = URI("https://migration-recommender-service.cca-pro.cerebro.c.#{current_region}.cloud.sap/public/api/v1/placeable-vm/project/#{@scoped_project_id}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        if ENV.key?("ELEKTRA_SSL_VERIFY_PEER") &&
          (ENV["ELEKTRA_SSL_VERIFY_PEER"] == "false")
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        big_vm_data = http.get(uri).body
      rescue StandardError => e
        render json: { error: "Clould not load bigVMData" }, status: 422
        return
      end
      render json: big_vm_data
    end

    private

    def prepare_data_for_view
      @project = services.identity.find_project!(@scoped_project_id)
      @js_data = {
        token: current_user.token,
        limes_api: current_user.service_url("resources"), # see also init.js -> configureAjaxHelper
        castellum_api: current_user.service_url("castellum"), # see also init.js -> configureCastellumAjaxHelper
        placement_api: current_user.service_url("placement"),
        flavor_data: fetch_baremetal_flavor_data,
        # do not load bigvm resources on init
        # use ajax instead (see: bigvm_resources action)
        # big_vm_resources: fetch_big_vm_data,
        docs_url: sap_url_for("documentation"),
      } # this will end in widget.config.scriptParams on JS side

      unless @project.nil?
        sharding_enabled = @project.sharding_enabled
        project_shards = @project.shards || []
        @js_data[:sharding_enabled] = sharding_enabled
        @js_data[:project_shards] = project_shards
        @js_data[:project_scope] = true
        @js_data[:path_to_enable_sharding] = plugin(
          "identity",
        ).project_enable_sharding_path()
      else
        # domain and ccadmin scope
        @js_data[:sharding_enabled] = false
        @js_data[:project_shards] = []
        @js_data[:project_scope] = false
        @js_data[:path_to_enable_sharding] = ""
      end

      # when this is true, the frontend will never try to generate quota requests
      @js_data[:is_foreign_scope] = (
        if (params[:override_project_id] || params[:override_domain_id])
          true
        else
          false
        end
      )

      # these variables (@XXX_override) trigger an infobox at the top of the
      # view informing that the user that they're viewing a foreign scope
      if params[:override_project_id]
        @project_override =
          services.identity.find_project!(params[:override_project_id])
      end
      if params[:override_domain_id]
        @domain_override =
          services.identity.find_domain!(params[:override_domain_id])
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
        m =
          (
            @@flavor_metadata_cache[
              f.id
            ] ||= cloud_admin.compute.find_flavor_metadata(f.id)
          )
        next if m.nil?

        primary = []
        primary << "#{f.vcpus} cores" if f.vcpus
        primary << "#{mib.format(f.ram.to_i)} RAM" if f.ram
        primary << "#{gib.format(f.disk.to_i)} disk" if f.disk
        result[f.name] = {
          primary: primary,
          secondary: m.attributes["catalog:description"] || "",
        }
      end
      return result
    end


  end
end
