require_dependency "resource_management/application_controller"

module ResourceManagement
  class CloudAdminController < ApplicationController
    
    authorization_required only: [:index, :show_area, :sync_now]

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

    def edit_capacity
      @capacity = ResourceManagement::Capacity.find(params[:id])
    end

    def update_capacity
      @capacity = ResourceManagement::Capacity.find(params[:id])

      if @capacity.update(params.require(:capacity).permit(:value))
        flash[:notice] = 'Resource updated.'
        render 'resource_management/cloud_admin/update_capacity.js'
      else
        @has_errors = true
        render action: :edit_capacity
      end
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

        # ensure that Capacity records exist for all resources
        capacity = capacities.find { |q| q.service == service && q.resource == resource }
        capacity ||= ResourceManagement::Capacity.create(
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
