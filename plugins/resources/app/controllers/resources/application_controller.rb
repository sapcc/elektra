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
        token:         current_user.token,
        limes_api:     current_user.service_url('resources'),
        castellum_api: current_user.service_url('castellum'),
        flavor_data:   fetch_baremetal_flavor_data,
        docs_url:      sap_url_for('documentation'),
        cluster_id:    params[:cluster_id] || 'current',
      }

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

  end
end
