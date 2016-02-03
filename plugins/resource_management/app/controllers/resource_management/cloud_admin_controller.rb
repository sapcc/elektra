require_dependency "resource_management/application_controller"

module ResourceManagement
  class CloudAdminController < ApplicationController

    before_filter :load_domain_resource, only: [:edit, :cancel, :update]
    before_filter :load_inquiry, only: [:review_request, :approve_request]

    authorization_required

    def index
      @all_services = ResourceManagement::Resource::KNOWN_SERVICES.
        select { |srv| srv[:enabled] }.
        map    { |srv| srv[:service] }
     
      prepare_data_for_resource_list(@all_services, overview: true)

      respond_to do |format|
        format.html
        format.js # update only status bars 
      end

    end

    def show_area
      @area = params.require(:area).to_sym
      @area_services = ResourceManagement::Resource::KNOWN_SERVICES.
        select { |srv| srv[:enabled] && srv[:area] == @area }.
        map    { |srv| srv[:service] }

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

      if @capacity.update(params.require(:capacity).permit(:value))
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
      @domain_status = prepare_domain_data_for_details_view(@domain_resource, resources, {})

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
      @domain_status = prepare_domain_data_for_details_view(@domain_resource, resources, {})

      respond_to do |format|
        format.js
      end
    end

    def review_request
      # prepare data for view
      _, _ = prepare_data_for_details_view(@resource.service.to_sym, @resource.name.to_sym)

      # calculate projected @cloud_status after approval
      @desired_quota = @inquiry.payload['desired_quota']
      @cloud_status_new = {
        capacity:         @cloud_status[:capacity],
        usage_sum:        @cloud_status[:usage_sum],
        domain_quota_sum: @cloud_status[:domain_quota_sum] - @resource.approved_quota + @desired_quota,
      }
    end

    def approve_request
      # set new quota value
      value = params.require(:resource).require(:approved_quota)
      begin
        @resource.approved_quota = @resource.data_type.parse(value)
      rescue ArgumentError => e
        @resource.add_validation_error(:approved_quota, 'is invalid: ' + e.message)
      end

      if @resource.save
        comment = "New domain quota is #{@resource.data_type.format(@resource.approved_quota)}"
        if params[:resource][:comment].present?
          comment += ", comment from approver: #{params[:resource][:comment]}"
        end
        services.inquiry.set_state(@inquiry.id, :approved, comment)
      else
        self.review_request
        render action: 'review_request'
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

      # sort domain entries by warning level, then by name
      sort_order_for = { 'danger' => 0, 'warning' => 1, '' => 2 }
      domains = domain_status.sort_by { |entry| [ sort_order_for[ entry[:warning_level] ], entry[:name] ] }
      # prepare the domains table
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

    def load_domain_resource
      @domain_resource = ResourceManagement::Resource.find(params.require(:id))
      raise ActiveRecord::RecordNotFound if @domain_resource.domain_id.nil? or not @domain_resource.project_id.nil?
    end

    def load_inquiry
      @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])

      unless @inquiry
        render html: 'Could not find inquiry!'
        return
      end

      unless current_user.is_allowed?("resource:management:cloud_admin_approve_request", {inquiry: {requester_uid: @inquiry.requester.uid}})
        render template: '/dashboard/not_authorized'
        return
      end

      # validate payload (these are all validations that I never expect to
      # fail, so I don't spend much time on presenting the errors)
      data = @inquiry.payload.symbolize_keys
      puts ">>>>>>> #{data.inspect}"

      @resource = ResourceManagement::Resource.find(data[:resource_id])
      if (not @resource) or @resource.domain_id.nil? or not @resource.project_id.nil?
        render html: 'Invalid resource record ID specified in inquiry payload!', status: :unprocessable_entity
        return
      end

      unless @resource.service.to_s == data[:service].to_s || @resource.name.to_s == data[:resource].to_s
        render html: 'Inquiry payload contains inconsistent data!', status: :unprocessable_entity
        return
      end

      if @resource.approved_quota >= data[:desired_quota].to_i
        render html: 'Approved quota is already larger than the requested value. Is this an old inquiry?', status: :unprocessable_entity
        return
      end

      @domain_name = services.identity.find_domain(@resource.domain_id).name
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
      domain_resources  = resources.where.not(domain_id: nil).where(project_id: nil)
      project_resources = resources.where.not(domain_id: nil).where.not(project_id: nil)

      # statistics for the whole cloud
      @cloud_status = {
        # special case if no capacity was found create a dummy object that the view can handle
        capacity:         ResourceManagement::Capacity.find_by(service: service, resource: resource) || ResourceManagement::Capacity.new(service: service, resource: resource, value: -1),
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

      # if there were no project resources...
      usage_sum ||= 0
      project_quota_sum ||= 0

      # usage exceeding approved quota is critical
      warning_level = 'danger'  if domain_resource.approved_quota < usage_sum
      # project quotas exceeding domain quota is dubious
      warning_level = 'warning' if domain_resource.approved_quota < project_quota_sum

      return {
        name:              domain_names[domain_id] || domain_id,
        domain_resource:   domain_resource,
        project_quota_sum: project_quota_sum,
        usage_sum:         usage_sum,
        warning_level:     warning_level || '',
      }
    end

  end
end
