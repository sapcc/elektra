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

    def edit
      @domain_resource = ResourceManagement::Resource.find(params.require(:id))
      raise ActiveRecord::RecordNotFound if @domain_resource.domain_id.nil? or not @domain_resource.project_id.nil?
    end

    def cancel
      @domain_resource = ResourceManagement::Resource.find(params.require(:id))
      raise ActiveRecord::RecordNotFound if @domain_resource.domain_id.nil? or not @domain_resource.project_id.nil?

      # prepare data for view
      resources = ResourceManagement::Resource.where(service: @domain_resource.service, name: @domain_resource.name)
      @domain_status = prepare_domain_data_for_details_view(@domain_resource, resources, {})

      respond_to do |format|
        format.js { render action: 'update' }
      end
    end

    def update
      # load Resource record to modify
      @domain_resource = ResourceManagement::Resource.find(params.require(:id))
      raise ActiveRecord::RecordNotFound if @domain_resource.domain_id.nil? or not @domain_resource.project_id.nil?

      # set new quota value
      value = params.require(:value)
      begin
        value = @domain_resource.data_type.parse(value)
      rescue ArgumentError => e
        render text: e.message, status: :bad_request
        return
      end

      @domain_resource.approved_quota = value
      @domain_resource.save

      # prepare data for view
      resources, _ = prepare_data_for_details_view(@domain_resource.service.to_sym, @domain_resource.name.to_sym)
      @domain_status = prepare_domain_data_for_details_view(@domain_resource, resources, {})

      respond_to do |format|
        format.js
      end
    end

    def details 
      @show_all_button = true if params[:overview] == 'true'

      @service  = params.require(:service).to_sym
      @resource = params.require(:resource).to_sym
      @area     = ResourceManagement::Resource::KNOWN_SERVICES.find { |s| s[:service] == @service }[:area]

      # get mapping of domain IDs to names
      domain_names = services.resource_management.driver.enumerate_domains()

      # some parts of this shared with update()
      resources, domain_resources = prepare_data_for_details_view(@service, @resource)

      # statistics per domain
      domain_status = []
      domain_resources.each do |domain_resource|
        domain_status << prepare_domain_data_for_details_view(domain_resource, resources, domain_names)
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

    def prepare_data_for_details_view(service, resource)
      # load resources
      resources = ResourceManagement::Resource.where(service: service, name: resource)
      domain_resources  = resources.where.not(domain_id: nil).where(project_id: nil)
      project_resources = resources.where.not(domain_id: nil).where.not(project_id: nil)

      # statistics for the whole cloud
      @cloud_status = {
        capacity:         ResourceManagement::Capacity.find_by(service: service, resource: resource),
        usage_sum:        project_resources.pluck("SUM(usage)").first,
        domain_quota_sum: domain_resources.pluck("SUM(approved_quota)").first,
      }

      # needed for further processing in details() action
      return resources, domain_resources
    end

    # Prepare data for a single domain (a row in the "Details" table).
    # `resources` and `domain_names` are results of previous computations or
    # API calls.
    def prepare_domain_data_for_details_view(domain_resource, resources, domain_names)
      domain_id = domain_resource.domain_id

      project_quota_sum, usage_sum = resources.
        where(domain_id: domain_id).where.not(project_id: nil).
        pluck("SUM(approved_quota), SUM(usage)").first

      return {
        name:              domain_names[domain_id] || domain_id,
        domain_resource:   domain_resource,
        project_quota_sum: project_quota_sum || 0,
        usage_sum:         usage_sum || 0,
      }
    end

  end
end
