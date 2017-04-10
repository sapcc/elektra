require_dependency "resource_management/application_controller"

module ResourceManagement
  class DomainAdminController < ::ResourceManagement::ApplicationController

    before_filter :load_project_resource, only: [:edit, :cancel, :update]
    before_filter :load_domain_resource, only: [:new_request, :create_request, :reduce_quota, :confirm_reduce_quota]
    before_filter :load_inquiry, only: [:review_request, :approve_request]
    before_filter :load_package_inquiry, only: [:review_package_request, :approve_package_request]

    authorization_required

    def index
      @domain = services.resource_management.find_domain(@scoped_domain_id)
      @min_updated_at = @domain.services.map(&:min_updated_at).min
      @max_updated_at = @domain.services.map(&:max_updated_at).max

      # find resources to show
      @critical_resources = @domain.resources.reject do |res|
        res.backend_quota.nil? and not res.infinite_backend_quota? and res.quota >= res.projects_quota
      end

      @index = true
    end

    def show_area(area = nil)
      @area = area || params.require(:area).to_sym

      # which services belong to this area?
      @area_services = ResourceManagement::ServiceConfig.in_area(@area)
      raise ActiveRecord::RecordNotFound, "unknown area #{@area}" if @area_services.empty?

      @domain = services.resource_management.find_domain(@scoped_domain_id, services: @area_services.map(&:catalog_type))
      @resources = @domain.resources
      @min_updated_at = @domain.services.map(&:min_updated_at).min
      @max_updated_at = @domain.services.map(&:max_updated_at).max
    end

    def edit
      # please do not delete
    end

    def cancel
      respond_to do |format|
        format.js { render action: 'update' }
      end
    end

    def update
      # validate new quota value
      value = params.require(:value)
      begin
        value = @project_resource.data_type.parse(value)
        raise ArgumentError, 'New quota may not be lower than current usage!' if value < @project_resource.usage
      rescue ArgumentError => e
        render text: e.message, status: :bad_request
        return
      end

      # check if the new project quota fits within the domain's budget
      old_project_quota_sum = ResourceManagement::Resource.
        where(domain_id: @scoped_domain_id, service: @project_resource.service, name: @project_resource.name).
        where.not(project_id: nil).
        pluck('SUM(GREATEST(approved_quota, current_quota, 0))').first

      new_project_quota_sum = old_project_quota_sum - @project_resource.approved_quota + value
      @domain_resource = ResourceManagement::Resource.find_by(
        domain_id: @scoped_domain_id, project_id: nil,
        service: @project_resource.service, name: @project_resource.name,
      )
      if value < 0 or (value > @project_resource.approved_quota and new_project_quota_sum > @domain_resource.approved_quota)
        max_value = @domain_resource.approved_quota - old_project_quota_sum + @project_resource.approved_quota
        msg = "Domain quota for #{@project_resource.service}/#{@project_resource.name} exceeded (maximum acceptable project quota is #{@project_resource.config.data_type.format(max_value)})"
        render text: msg, status: :bad_request
        return
      end

      # do only a upgrade if the values are different otherwise it meaningless
      if @project_resource.approved_quota != value || @project_resource.current_quota != value
        @project_resource.approved_quota = value
        @project_resource.current_quota  = value
        services.resource_management.apply_current_quota(@project_resource) # apply quota in target service
        @project_resource.save
      end

      # prepare data for view
      prepare_data_for_details_view(@project_resource.service.to_sym, @project_resource.name.to_sym)

      respond_to do |format|
        format.js
      end
    end

    def confirm_reduce_quota
      prepare_data_for_details_view(@resource.service.to_sym, @resource.name.to_sym)
    end

    def reduce_quota
      prepare_data_for_details_view(@resource.service.to_sym, @resource.name.to_sym)
      value = params[:resource][:approved_quota]

      if value.empty?
        @resource.add_validation_error(:approved_quota, "empty value is invalid")
      else
        begin
          parsed_value = @resource.data_type.parse(value)
          # pre check value
          if @resource.approved_quota < parsed_value
              @resource.add_validation_error(:approved_quota, "wrong value: because the wanted quota value of #{value} is higher than your approved quota")
          elsif @resource_status[:current_quota_sum] > parsed_value
            @resource.add_validation_error(:approved_quota, "wrong value: it is now allowed to reduce the quota below your current used quota value of #{@resource_status[:current_quota_sum]}")
          elsif @resource.approved_quota == parsed_value
              @resource.add_validation_error(:approved_quota, "wrong value: because the wanted quota value is the same as your approved quota")
          else
            @resource.approved_quota = parsed_value
          end
        rescue ArgumentError => e
          @resource.add_validation_error(:approved_quota, 'is invalid: ' + e.message)
        end
      end

      # save the new quota to database
      if @resource.save
        show_area(@resource.service.to_sym)
      else
        # reload the reduce quota window with error
        respond_to do |format|
          format.html do
            render action: 'confirm_reduce_quota'
          end
        end
      end
    end

    def review_request
      @desired_quota = @inquiry.payload['desired_quota']
      @maximum_quota = @domain_resource.quota - @domain_resource.projects_quota + @project_resource.quota

      # calculate projected domain status after approval
      @domain_resource_projected = @domain_resource.clone
      @domain_resource_projected.projects_quota += @desired_quota - @project_resource.quota
    end

    def approve_request
      begin
        @desired_quota = @project_resource.data_type.parse(params.require(:new_style_resource).require(:quota))
      rescue => e
        @project_resource.add_validation_error(:quota, 'is invalid: ' + e.message)
      end

      # check that domain quota is not exceeded
      @maximum_quota = @domain_resource.quota - @domain_resource.projects_quota + @project_resource.quota
      if @desired_quota and @desired_quota > @maximum_quota
        max_quota_str = @project_resource.data_type.format(@maximum_quota)
        @project_resource.add_validation_error(:quota, "is too large (would exceed total domain quota), maximum acceptable project quota is #{max_quota_str}")
      end

      # do not even attempt to edit the @project_resource when we know the value to be invalid (this
      # would break the re-rendering of the "review_request" view)
      if @project_resource.valid?
        @project_resource.quota = @desired_quota
      end

      if @project_resource.save
        comment = "New project quota is #{@project_resource.data_type.format(@project_resource.quota)}"
        if params[:new_style_resource][:comment].present?
          comment += ", comment from approver: #{params[:new_style_resource][:comment]}"
        end
        services.inquiry.set_inquiry_state(@inquiry.id, :approved, comment)
        @services_with_error = @project_resource.services_with_error
      else
        self.review_request
        render action: 'review_request'
      end
    end

    def review_package_request
      @project = services.resource_management.find_project(@scoped_domain_id, @inquiry.project_id)
      @domain  = services.resource_management.find_domain(@scoped_domain_id)

      @target_project_name = services.identity.find_project(@inquiry.project_id).name

      # check if request fits into domain quotas
      @can_approve = true
      # show only those resources in the review screen where the approval of
      # the request would increase the current_quota allocated to the project
      @relevant_resources = []
      ResourceManagement::ResourceConfig.all.each do |cfg|
        domain_resource  =  @domain.find_resource(cfg)
        project_resource = @project.find_resource(cfg)

        new_projects_quota = domain_resource.projects_quota - project_resource.quota + cfg.value_for_package(@package)
        if new_projects_quota > domain_resource.quota
          @can_approve = false
        end

        if cfg.value_for_package(@package) > project_resource.quota
          @relevant_resources.append(cfg)
        end
      end
    end

    def approve_package_request
      # apply quotas from package to project, but take existing approved quotas into account
      @project = services.resource_management.find_project(@scoped_domain_id, @inquiry.project_id)
      @project.resources.each do |res|
        new_quota = res.config.value_for_package(@package)
        res.quota = [ res.quota, new_quota ].max
      end

      if @project.save
        @services_with_error = @project.services_with_error
        services.inquiry.set_inquiry_state(@inquiry.id, :approved, 'Approved')
        render action: 'approve_request'
      end
    end

    def new_request
      # prepare data for usage display
      prepare_data_for_details_view(@resource.service.to_sym, @resource.name.to_sym)
    end

    def create_request
      # parse and validate value
      old_value = @resource.approved_quota
      data_type = @resource.data_type
      value = params.require(:resource).require(:approved_quota)
      begin
        value = data_type.parse(value)
        @resource.approved_quota = value
        if value <= old_value || data_type.format(value) == data_type.format(old_value)
          # the second condition catches slightly larger values that round to the same representation, e.g. 100.000001 GiB
          @resource.add_validation_error(:approved_quota, 'must be larger than current value')
        end
      rescue ArgumentError => e
        @resource.add_validation_error(:approved_quota, 'is invalid: ' + e.message)
      end

      # back to square one if validation failed
      unless @resource.validate
        @has_errors = true
        # prepare data for usage display
        prepare_data_for_details_view(@resource.service.to_sym, @resource.name.to_sym)
        render action: :new_request
        return
      end

      # create inquiry
      base_url    = plugin('resource_management').cloud_admin_area_path(area: @resource.config.service.area.to_s, domain_id: Rails.configuration.cloud_admin_domain,
                                                                        project_id: Rails.configuration.cloud_admin_project)
      overlay_url = plugin('resource_management').cloud_admin_review_request_path(domain_id: Rails.configuration.cloud_admin_domain,
                                                                                  project_id: Rails.configuration.cloud_admin_project)

      inquiry = services.inquiry.create_inquiry(
        'domain_quota',
        "domain #{@scoped_domain_name}: add #{@resource.data_type.format(value - old_value)} #{@resource.service}/#{@resource.name}",
        current_user,
        {
          resource_id: @resource.id,
          service: @resource.service,
          resource: @resource.name,
          desired_quota: value,
        },
        service_user.list_ccadmins(),
        {
          "approved": {
            "name": "Approve",
            "action": "#{base_url}?overlay=#{overlay_url}",
          },
        },
        nil,
        {
            domain_name: @scoped_domain_name,
            region: current_region
        }
      )
      if inquiry.errors?
        @has_errors = true
        # prepare data for usage display
        prepare_data_for_details_view(@resource.service.to_sym, @resource.name.to_sym)
        render action: :new_request
        return
      end

      respond_to do |format|
        format.js
      end
    end

    def details
      @show_all_button = true if params[:overview] == 'true'

      # sort
      @sort_order  = params[:sort_order] || 'asc'
      @sort_column = params[:sort_column] || ''
      sort_by = @sort_column.gsub("_column", "")

      @service  = params.require(:service).to_sym
      @resource = params.require(:resource).to_sym
      @area     = ResourceManagement::ServiceConfig.find(@service).area

      # some parts of data collection are shared with update()
      project_resources = prepare_data_for_details_view(@service, @resource, sort_by, @sort_order)

      projects = project_resources
      # show danger and warning projects on top if no sort by is given
      if sort_by.empty?
        ## prepare the projects table
        projects = project_resources.to_a.sort_by do |project_resource|
          # find warning level for project
          warning_level = view_context.warning_level_for_project(project_resource)
          sort_order    = { "danger" => 0, "warning" => 1 }.fetch(warning_level, 2)
          # sort projects by warning level, then by name
          project_name = project_resource.scope_name || project_resource.project_id
          [ sort_order, project_name.downcase ]
        end
      end

      @projects = Kaminari.paginate_array(projects).page(params[:page]).per(6)

      respond_to do |format|
        format.html
        format.js
      end

    end

    def sync_now
      options = {}
      begin
        services.resource_management.sync_domain(
          @scoped_domain_id, @scoped_domain_name,
          timeout_secs: 40,  # abort after 40 seconds to avoid HTTP connection timeout (~1 minute)
          refresh_secs: 600, # do not try to update data that's newer than 10 minutes
        )
      rescue Interrupt
        options[:flash] = { error: "Could not sync all projects before timeout. Please try again." }
      end
      begin
        redirect_to :back, options
      rescue ActionController::RedirectBackError
        redirect_to admin_path(), options
      end
    end

    private

    def load_project_resource
      @project_resource = ResourceManagement::Resource.find(params.require(:id))
      raise ActiveRecord::RecordNotFound if @project_resource.domain_id != @scoped_domain_id or @project_resource.project_id.nil?
    end

    def load_domain_resource
      @resource = ResourceManagement::Resource.find(params.require(:id))
      raise ActiveRecord::RecordNotFound if @resource.domain_id != @scoped_domain_id or not @resource.project_id.nil?
    end

    def load_inquiry
      @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])
      # Error Handling
      unless @inquiry
        render html: 'Could not find inquiry!'
        return
      end

      enforce_permissions("resource_management:admin_approve_request", {inquiry: {requester_uid: @inquiry.requester.uid}})

      # load additional data
      data = @inquiry.payload.symbolize_keys
      raise ArgumentError, "inquiry #{@inquiry.id} has not been migrated to new format!" if data.include?(:resource_id)

      @project_resource = services.resource_management.find_project(
        @scoped_domain_id, @inquiry.project_id,
        services:  [ data[:service]  ],
        resources: [ data[:resource] ],
      ).resources.first or raise ActiveRecord::RecordNotFound

      @domain_resource = services.resource_management.find_domain(
        @scoped_domain_id,
        services:  [ data[:service]  ],
        resources: [ data[:resource] ],
      ).resources.first or raise ActiveRecord::RecordNotFound
    end

    def load_package_inquiry
      @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])
      # Error Handling
      unless @inquiry
        render html: 'Could not find inquiry!'
        return
      end

      enforce_permissions("resource_management:admin_approve_package_request", {inquiry: {requester_uid: @inquiry.requester.uid}})

      # load additional data
      @package = @inquiry.payload.symbolize_keys[:package]

      # if project resources have not been created yet, do so now
      project_resources = ResourceManagement::Resource.where(domain_id: @scoped_domain_id, project_id: @inquiry.project_id)
      if project_resources.where.not(service: 'resource_management').count == 0
        services.resource_management.sync_project(@scoped_domain_id, @target_project_id)
      end
    end

    def prepare_data_for_resource_list(services, options={})
      # load resources for domain and projects within this domain
      resources = ResourceManagement::Resource.
        where(domain_id: @scoped_domain_id, service: services)

      domain_resources  = resources.where(project_id: nil).to_a
      project_resources = resources.where.not(project_id: nil)

      # check data age (see _data_age partial view)
      @min_updated_at, @max_updated_at = project_resources.pluck("MIN(updated_at), MAX(updated_at)").first

      # examine project quotas and usage
      stats = project_resources.
        group("service, name").
        pluck("service, name, MIN(current_quota), SUM(GREATEST(current_quota,0)), SUM(usage)")

      # prepare data for each resource for display
      @resource_status = Hash.new { |h,k| h[k] = [] }
      stats.each do |stat|
        service, name, min_current_quota, current_quota_sum, usage_sum = *stat
        has_infinite_current_quota = min_current_quota < 0

        # use existing domain resource, or create an empty mock object as a placeholder
        domain_resource = domain_resources.find { |q| q.service == service && q.name == name }
        domain_resource ||= ResourceManagement::Resource.new(
          service: service, name: name, approved_quota: -1,
        )

        # on overview, show only critical quotas
        is_critical = current_quota_sum > domain_resource.approved_quota or has_infinite_current_quota
        if options[:overview]
          next unless is_critical
        end

        # show warning in infobox when there are critical quotas
        @show_warning = true if is_critical

        @resource_status[service.to_sym] << {
          name:                       name,
          current_quota_sum:          current_quota_sum,
          usage_sum:                  usage_sum,
          has_infinite_current_quota: has_infinite_current_quota,
          domain_resource:            domain_resource,
        }
      end
    end

    # Some data collection that's shared between the details() and update() actions.
    def prepare_data_for_details_view(service, resource, sort_by = "", sort_order = "ASC")
      # load domain resource and corresponding project resources
      resources = ResourceManagement::Resource.
        where(domain_id: @scoped_domain_id, service: service, name: resource)

      domain_resource   = resources.where(project_id: nil).first

      min_current_quota ,current_quota_sum ,usage_sum = 0,0,0
      if sort_by.empty?
        project_resources = resources.where.not(project_id: nil)
        # statistics over project resources
        min_current_quota, current_quota_sum, usage_sum = project_resources.
          pluck("MIN(current_quota), SUM(GREATEST(current_quota,0)), SUM(usage)").first
      else
        project_resources = resources.where.not(project_id: nil).order("#{sort_by} #{sort_order.upcase}")
      end

      # when no domain resource record exists yet, use an empty mock object
      domain_resource ||= ResourceManagement::Resource.new(
        domain_id: @scoped_domain_id, service: service, name: resource, approved_quota: 0,
      )

      @resource_status = {
        name:                       resource,
        current_quota_sum:          current_quota_sum,
        usage_sum:                  usage_sum,
        has_infinite_current_quota: min_current_quota < 0,
        domain_resource:            domain_resource,
      }

      return project_resources # this is used for further data collection by details()
    end

  end
end
