require_dependency "resource_management/application_controller"

module Resources
  class QuotaUsageController < ::ResourceManagement::ApplicationController
    authorization_required

    QUOTA_RESOURCES = {
      compute: {service_type: :compute, resource_names: [:instances, :cores, :ram]},
      block_storage: {service_type: :volumev2, resource_names: [:volumes, :snapshots, :capacity]},
      loadbalancing: {service_type: :network, resource_names: [:loadbalancers, :listeners, :pools, :l7policies]},
      networking: {service_type: :network, resource_names: [:floating_ips, :networks, :subnets, :routers] },
      shared_filesystem_storage: { service_type: :sharev2, resource_names: [:gigabytes, :shares, :snapshots, :share_networks, :share_groups] },
      dns_service: { service_type: :dns, resource_names: [:zones, :recordsets]}
    }

    def index
      render json: usage(params[:type])
    end

    private 

    def usage(type)
      resources = QUOTA_RESOURCES[type.to_sym] if type
      return [] unless resources
      usage = services.send(type).usage if services.respond_to?(type) && services.send(type).respond_to?(:usage)

      services.resource_management.quota_data(
        current_user.domain_id || current_user.project_domain_id,
        current_user.project_id, 
        resources[:resource_names].map do |name|
          {service_type: resources[:service_type], resource_name: name}
        end
      ).map do |quota| 
        {
          name: quota.name,
          quota: quota.quota,
          usage: quota.usage,
          label: quota.available_as_display_string
        }
      end
    end
  end
end
