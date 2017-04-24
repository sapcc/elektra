require_dependency "resource_management/application_controller"

module ResourceManagement
  class AutomationController < ::ResourceManagement::ApplicationController

    # requires cloud_admin permission to use (intended for use with a privileged technical user)
    authorization_required

    # bypass Terms-of-Use check for technical users
    def check_terms_of_use
      return
    end

    def dump_data
      region = [Rails.application.config.default_region].flatten.first
      monsoon2_domain_id = ResourceManagement::Resource.where(scope_name: 'monsoon2', project_id: nil).pluck(:domain_id).first
      # when dumping project resource data, skip internal dummy records with service == "resource_management"
      project_resources = ResourceManagement::Resource.where("project_id IS NOT NULL AND service != 'resource_management' AND domain_id != ?", monsoon2_domain_id)

      full_data = {
        metadata: { version: 1 },
        data: project_resources.map do |res|
          dt = res.data_type
          {
            domain_id: res.domain_id,
            project_id: res.project_id,
            resource_class: res.service,
            resource_type: res.name,
            quota: dt.normalize(res.current_quota),
            usage: dt.normalize(res.usage),
            last_information_at: res.updated_at.iso8601,
            region: region,
          }
        end,
      }
      render json: full_data.to_json
    end

  end
end
