require_dependency "resource_management/application_controller"

module ResourceManagement
  class CloudAdminController < ::ResourceManagement::ApplicationController

    before_filter :load_domain_resource, only: [:edit, :cancel, :update]
    before_filter :load_inquiry, only: [:review_request, :approve_request]

    authorization_required

    def index
      @all_services = ResourceManagement::ServiceConfig.all.map(&:name)
      prepare_data_for_resource_list(@all_services, overview: true)

      respond_to do |format|
        format.html
        format.js # update only status bars
      end
    end

    def show_area
      @area = params.require(:area).to_sym
      @area_services = ResourceManagement::ServiceConfig.in_area(@area).map(&:name)
      prepare_data_for_resource_list(@area_services)

      respond_to do |format|
        format.html
        format.js # update only status bars
      end

    end

    def edit_capacity
      @capacity = ResourceManagement::Capacity.find(params[:id])
    end

    def update_capacity
      @capacity = ResourceManagement::Capacity.find(params[:id])

      if @capacity.update(params.require(:capacity).permit(:value, :comment))
        render 'resource_management/cloud_admin/update_capacity.js'
      else
        @has_errors = true
        render action: :edit_capacity
      end
    end

    def edit
    end

    def cancel
      # prepare data for view
      resources = ResourceManagement::Resource.where(service: @domain_resource.service, name: @domain_resource.name)
      @domain_status = prepare_domain_data_for_details_view(@domain_resource, resources)

      respond_to do |format|
        format.js { render action: 'update' }
      end
    end

    def update
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
      @domain_status = prepare_domain_data_for_details_view(@domain_resource, resources)

      respond_to do |format|
        format.js
      end
    end

    def review_request
      @desired_quota = @inquiry.payload['desired_quota']

      # calculate projected cluster status after approval
      @cluster_resource_projected = @cluster_resource.clone
      @cluster_resource_projected.domains_quota += @desired_quota - @domain_resource.quota
    end

    def approve_request
      old_quota = @domain_resource.quota
      begin
        @domain_resource.quota = @domain_resource.data_type.parse(params.require(:new_style_resource).require(:quota))
      rescue ArgumentError => e
        @domain_resource.add_validation_error(:approved_quota, 'is invalid: ' + e.message)
      end

      if @domain_resource.save
        comment = "New domain quota is #{@domain_resource.data_type.format(@domain_resource.quota)}"
        if params[:new_style_resource][:comment].present?
          comment += ", comment from approver: #{params[:new_style_resource][:comment]}"
        end
        services.inquiry.set_inquiry_state(@inquiry.id, :approved, comment)
      else
        @domain_resource.quota = old_quota
        self.review_request
        render action: 'review_request'
      end
    end

    def details
      @show_all_button = true if params[:overview] == 'true'

      @service  = params.require(:service).to_sym
      @resource = params.require(:resource).to_sym
      @area     = ResourceManagement::ServiceConfig.find(@service).area

      # some parts of this shared with update()
      resources, domain_resources = prepare_data_for_details_view(@service, @resource)

      # statistics per domain
      domain_status = []
      domain_resources.each do |domain_resource|
        domain_status << prepare_domain_data_for_details_view(domain_resource, resources)
      end

      # sort domain entries by warning level, then by name
      sort_order_for = { 'danger' => 0, 'warning' => 1, '' => 2 }
      domains = domain_status.sort_by { |entry| [ sort_order_for[ entry[:warning_level] ], entry[:name].downcase ] }
      # prepare the domains table
      @domains = Kaminari.paginate_array(domains).page(params[:page]).per(6)
    end

    def sync_now
      service = services.resource_management
      service.sync_all_domains
      begin
        redirect_to :back
      rescue ActionController::RedirectBackError
        render text: "Synced!"
      end
    end

    private

    def load_domain_resource
      domain = services.resource_management.find_domain(
        params.require(:domain),
        services:  [ params.require(:service) ],
        resources: [ params.require(:resource) ],
      ) or raise ActiveRecord::RecordNotFound, "domain #{params[:domain]} not found"
      @domain_resource = domain.resources.first or raise ActiveRecord::RecordNotFound, "resource not found"
    end

    def load_inquiry
      @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])
      unless @inquiry
        render html: 'Could not find inquiry!'
        return
      end

      enforce_permissions("resource_management:cloud_admin_approve_request", {inquiry: {requester_uid: @inquiry.requester.uid}})

      # load additional data
      data = @inquiry.payload.symbolize_keys
      raise ArgumentError, "inquiry #{@inquiry.id} has not been migrated to new format!" if data.include?(:resource_id)

      @domain_resource = services.resource_management.find_domain(
        @inquiry.domain_id,
        services:  [ data[:service]  ],
        resources: [ data[:resource] ],
      ).resources.first or raise ActiveRecord::RecordNotFound

      @cluster_resource = services.resource_management.find_cluster(
        services:  [ data[:service]  ],
        resources: [ data[:resource] ],
      ).resources.first or raise ActiveRecord::RecordNotFound
    end

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

    def prepare_data_for_details_view(service, resource)
      # load resources
      resources = ResourceManagement::Resource.where(service: service, name: resource)
      domain_resources  = resources.where(project_id: nil)
      project_resources = resources.where.not(project_id: nil)

      # statistics for the whole cloud
      @cloud_status = {
        # special case if no capacity was found create a dummy object that the view can handle
        capacity:         ResourceManagement::Capacity.find_by(service: service, resource: resource) || ResourceManagement::Capacity.new(service: service, resource: resource, value: -1),
        usage_sum:        project_resources.pluck("SUM(usage)").first || 0.0, # 0.0 to avoid nil exception in case resource was never determined before
        domain_quota_sum: domain_resources.pluck("SUM(approved_quota)").first || 0.0, # 0.0 to avoid nil exception in case resource was never determined before
      }

      # needed for further processing in details() action
      return resources, domain_resources
    end

    # Prepare data for a single domain (a row in the "Details" table).
    # `resources` is the result of previous computations or API calls.
    def prepare_domain_data_for_details_view(domain_resource, resources)
      domain_id = domain_resource.domain_id

      project_quota_sum, usage_sum = resources.
        where(domain_id: domain_id).where.not(project_id: nil).
        pluck("SUM(approved_quota), SUM(usage)").first

      # if there were no project resources...
      usage_sum ||= 0
      project_quota_sum ||= 0

      # usage exceeding approved quota is critical
      warning_level = 'danger'  if domain_resource.approved_quota < usage_sum
      # project quotas exceeding domain quota is dubious
      warning_level = 'warning' if domain_resource.approved_quota < project_quota_sum

      return {
        name:              domain_resource.scope_name || domain_id,
        domain_resource:   domain_resource,
        project_quota_sum: project_quota_sum,
        usage_sum:         usage_sum,
        warning_level:     warning_level || '',
      }
    end

  end
end
