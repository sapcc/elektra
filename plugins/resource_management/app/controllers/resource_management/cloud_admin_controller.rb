require_dependency "resource_management/application_controller"

module ResourceManagement
  class CloudAdminController < ApplicationController

    def index
      @all_services = ResourceManagement::Resource::KNOWN_SERVICES.
        select { |srv| srv[:enabled] }.
        map    { |srv| srv[:service] }

      prepare_data_for_resource_list(@all_services, overview: true)
    end

    def show_area
      @area = params.require(:area).to_sym
      @area_services = ResourceManagement::Resource::KNOWN_SERVICES.
        select { |srv| srv[:enabled] && srv[:area] == @area }.
        map    { |srv| srv[:service] }

      prepare_data_for_resource_list(@area_services)
    end

    def details 
      @show_all_button = true if params[:overview] == 'true'

      @service  = params.require(:service).to_sym
      @resource = params.require(:resource).to_sym
      @area     = ResourceManagement::Resource::KNOWN_SERVICES.find { |s| s[:service] == @service }[:area]

      # load resources
      resources = ResourceManagement::Resource.where(service: @service, name: @resource)
      domain_resources  = resources.where.not(domain_id: nil).where(project_id: nil)
      project_resources = resources.where.not(domain_id: nil).where.not(project_id: nil)

      # statistics for the whole cloud
      @cloud_status = {
        capacity:         ResourceManagement::Capacity.find_by(service: @service, resource: @resource),
        usage_sum:        project_resources.pluck("SUM(usage)").first,
        domain_quota_sum: domain_resources.pluck("SUM(approved_quota)").first,
      }

      # statistics per domain
      domain_status = []
      domain_resources.each do |domain_resource|
        project_quota_sum, usage_sum = resources.
          where(domain_id: domain_resource.domain_id).where.not(project_id: nil).
          pluck("SUM(approved_quota), SUM(usage)").first

        domain_status << {
          name:              domain_resource.domain_id, # TODO: retrieve domain names
          domain_resource:   domain_resource,
          project_quota_sum: project_quota_sum || 0,
          usage_sum:         usage_sum || 0,
        }
      end

      # prepare the domains table
      domains = domain_status.sort_by { |entry| entry[:name] }
      @domains = Kaminari.paginate_array(domains).page(params[:page]).per(6)
    end

    def sync_now
      service = services.resource_management
      service.sync_all_domains(with_projects: true)
      begin
        redirect_to :back
      rescue ActionController::RedirectBackError
        render text: "Synced!"
      end
    end

    private

    def prepare_data_for_resource_list(services, options={})
      # load capacities
      capacities = ResourceManagement::Capacity.where(service: services).to_a

      # examine project usage
      project_resources = ResourceManagement::Resource.
        where(cluster_id: nil, service: services).
        where.not(project_id: nil)
      stats = project_resources.group("service, name").pluck("service, name, SUM(usage)")

      # check data age (see _data_age partial view)
      @min_updated_at, @max_updated_at = project_resources.pluck("MIN(updated_at), MAX(updated_at)").first

      # prepare data for each resource for display
      @resource_status = Hash.new { |h,k| h[k] = [] }
      stats.each do |stat|
        service, resource, usage_sum = *stat

        # use existing domain resource, or create an empty mock object as a placeholder
        capacity = capacities.find { |q| q.service == service && q.resource == resource }
        capacity ||= ResourceManagement::Capacity.new(
          service: service, resource: resource, value: -1,
        )

        # on overview, show only critical usage
        if options[:overview]
          next unless usage_sum > 0.8 * capacity.value
        end

        @resource_status[service.to_sym] << {
          name:      resource,
          usage_sum: usage_sum,
          capacity:  capacity,
        }
      end
    end

  end
end
