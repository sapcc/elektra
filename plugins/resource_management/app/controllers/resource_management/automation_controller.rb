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
      result = []

      legacy_names = {
        :compute        => 'compute',
        :dns            => 'dns',
        :loadbalancing  => 'lbaas2',
        :networking     => 'networking',
        :'object-store' => 'object_storage',
        :sharev2        => 'shared_filesystem_storage',
        :volumev2       => 'block_storage',
      }

      services.resource_management.list_domains(service: ['none']).each do |domain|
        services.resource_management.list_projects(domain.id).each do |project|
          project.services.each do |srv|
            srv.resources.each do |res|
              dt = res.data_type
              result << {
                domain_id: domain.id,
                domain_name: domain.name,
                project_id: res.project_id,
                project_name: project.name,
                resource_class: legacy_names[res.category == :'' ? res.service_type : res.category],
                resource_type: res.name,
                quota: dt.normalize(res.backend_quota || res.quota),
                usage: dt.normalize(res.usage),
                last_information_at: srv.updated_at.iso8601,
                region: region,
              }
            end
          end
        end
      end

      full_data = {
        metadata: { version: 1 },
        data: result,
      }
      render json: full_data.to_json
    end

  end
end
