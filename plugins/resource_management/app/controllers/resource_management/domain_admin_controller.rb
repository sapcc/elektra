require_dependency "resource_management/application_controller"

module ResourceManagement
  class DomainAdminController < ::ResourceManagement::ApplicationController

    before_filter :load_project_resource, only: [:edit, :cancel, :update]
    before_filter :load_domain_resource, only: [:new_request, :create_request, :reduce_quota, :confirm_reduce_quota, :cancel, :update]
    before_filter :load_inquiry, only: [:review_request, :approve_request]
    before_filter :load_package_inquiry, only: [:review_package_request, :approve_package_request]

    authorization_required

    def index
      @domain = services_ng.resource_management.find_domain(@scoped_domain_id)
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

      @domain = services_ng.resource_management.find_domain(@scoped_domain_id, service: @area_services.map(&:catalog_type))
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
      @domain_resource = @resource # XXX cleanup

      old_quota = @project_resource.quota
      begin
        new_quota = @project_resource.data_type.parse(params.require(:value))
      rescue ArgumentError => e
        render text: e.message, status: :bad_request
        return
      end

      # check if new quota fits within domain quota (TODO: this should be done by Limes)
      old_projects_quota = @domain_resource.projects_quota
      new_projects_quota = old_projects_quota - old_quota + new_quota

      if new_quota < 0 or new_projects_quota > @domain_resource.quota
        max_value = @domain_resource.quota - old_projects_quota + old_quota
        msg = "Domain quota for #{@project_resource.service}/#{@project_resource.name} exceeded (maximum acceptable project quota is #{@project_resource.data_type.format(max_value)})"
        render text: msg, status: :bad_request
        return
      end

      # set quota
      @project_resource.quota = new_quota
      unless @project_resource.save
        render text: @project_resource.errors.full_messages.to_sentence, status: :bad_request
        return
      end

      # make sure that row is not rendered with red background color
      @project_resource.backend_quota = nil
      # make sure that usage bars are rendered with correct quota sum
      @domain_resource.projects_quota += new_quota - old_quota

      respond_to do |format|
        format.js
      end
    end

    def confirm_reduce_quota
      # please do not delete
    end

    def reduce_quota
      old_quota = @resource.quota
      value = params[:new_style_resource][:quota]
      if value.empty?
        @resource.add_validation_error(:quota, 'is missing')
      else
        begin
          value = @resource.data_type.parse(value)

          # NOTE: there are additional validations in the NewStyleResource class
          if @resource.quota < value
            @resource.add_validation_error(:quota, 'is higher than current quota')
          else
            @resource.quota = value
          end
        rescue ArgumentError => e
          @resource.add_validation_error(:quota, 'is invalid: ' + e.message)
        end
      end

      # save the new quota to database
      if @resource.save
        show_area(@resource.config.service.area)
      else
        # reload the reduce quota window with error
        @resource.quota = old_quota
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

      @project_name = services_ng.identity.find_project(@inquiry.project_id).name

      # calculate projected domain status after approval
      @domain_resource_projected = @domain_resource.clone
      @domain_resource_projected.projects_quota += @desired_quota - @project_resource.quota
    end

    def approve_request
      old_quota = @project_resource.quota
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

      @project_resource.quota = @desired_quota

      if @project_resource.save
        comment = "New project quota is #{@project_resource.data_type.format(@project_resource.quota)}"
        if params[:new_style_resource][:comment].present?
          comment += ", comment from approver: #{params[:new_style_resource][:comment]}"
        end
        services.inquiry.set_inquiry_state(@inquiry.id, :approved, comment)
      else
        @project_resource.quota = old_quota # reset quota to render view correctly
        self.review_request
        render action: 'review_request'
      end
    end

    def review_package_request
      @project = services_ng.resource_management.find_project(@scoped_domain_id, @inquiry.project_id)
      @domain  = services_ng.resource_management.find_domain(@scoped_domain_id)

      @target_project_name = services_ng.identity.find_project(@inquiry.project_id).name

      # check if request fits into domain quotas
      @can_approve = true
      # show only those resources in the review screen where the approval of
      # the request would increase the current_quota allocated to the project
      @relevant_resources = []
      ResourceManagement::ResourceConfig.all.each do |cfg|
        domain_resource  =  @domain.find_resource(cfg)
        project_resource = @project.find_resource(cfg)
        next if domain_resource.nil? or project_resource.nil?

        new_projects_quota = domain_resource.projects_quota - project_resource.quota + cfg.value_for_package(@package)
        if new_projects_quota > domain_resource.projects_quota and new_projects_quota > domain_resource.quota
          @can_approve = false
        end

        if cfg.value_for_package(@package) > project_resource.quota
          @relevant_resources.append(cfg)
        end
      end
    end

    def approve_package_request
      # apply quotas from package to project, but take existing approved quotas into account
      @project = services_ng.resource_management.find_project(@scoped_domain_id, @inquiry.project_id)
      @project.resources.each do |res|
        new_quota = res.config.value_for_package(@package)
        res.quota = [ res.quota, new_quota ].max
      end

      if @project.save
        @services_with_error = @project.services_with_error
        services.inquiry.set_inquiry_state(@inquiry.id, :approved, 'Approved')
        render action: 'approve_request'
      else
        @errors = @project.errors
        review_package_request
        render action: 'review_package_request'
      end
    end

    def new_request
      # please do not delete
    end

    def create_request
      old_value = @resource.quota
      data_type = @resource.data_type
      new_value = params.require(:new_style_resource).require(:quota)

      # parse and validate value
      begin
        new_value = data_type.parse(new_value)
        @resource.quota = new_value
        if new_value <= old_value || data_type.format(new_value) == data_type.format(old_value)
          # the second condition catches slightly larger values that round to the same representation, e.g. 100.000001 GiB
          @resource.add_validation_error(:quota, 'must be larger than current value')
        end
      rescue ArgumentError => e
        @resource.add_validation_error(:quota, 'is invalid: ' + e.message)
      end
      # back to square one if validation failed
      unless @resource.validate
        render action: :new_request
        return
      end

      # create inquiry
      cfg      = @resource.config
      base_url = plugin('resource_management').cloud_admin_area_path(
        area: cfg.service.area.to_s,
        domain_id:  Rails.configuration.cloud_admin_domain,
        project_id: Rails.configuration.cloud_admin_project,
      )
      overlay_url = plugin('resource_management').cloud_admin_review_request_path(
        domain_id:  Rails.configuration.cloud_admin_domain,
        project_id: Rails.configuration.cloud_admin_project,
      )

      inquiry = services.inquiry.create_inquiry(
        'domain_quota',
        "domain #{@scoped_domain_name}: add #{@resource.data_type.format(new_value - old_value)} #{cfg.service.name}/#{cfg.name}",
        current_user,
        {
          service: cfg.service.catalog_type,
          resource: cfg.name,
          desired_quota: new_value,
        },
        service_user.identity.list_ccadmins,
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

      service_type  = params.require(:service).to_s
      resource_name = params.require(:resource).to_sym
      @config       = ResourceManagement::ResourceConfig.all.find do |c|
        c.name == resource_name and c.service.catalog_type == service_type
      end or raise ActiveRecord::RecordNotFound, "no such resource"

      domain = services_ng.resource_management.find_domain(@scoped_domain_id, service: service_type, resource: resource_name.to_s)
      @domain_resource = domain.resources.first or raise ActiveRecord::RecordNotFound, "no such domain"
      projects = services_ng.resource_management.list_projects(@scoped_domain_id, service: service_type, resource: resource_name.to_s)
      @project_resources = projects.map { |p| p.resources.first }.reject(&:nil?)

      # show danger and warning projects on top if no sort by is given
      if sort_by.empty?
        ## prepare the projects table
        @project_resources = @project_resources.sort_by do |res|
          # warn about projects with mismatching frontend<->backend quota
          sort_order = res.backend_quota.nil? ? 1 : 0
          # sort projects by warning level, then by name
          [ sort_order, (res.project_name || res.project_id).downcase ]
        end
      else
        sort_method = sort_by.to_sym
        @project_resources.sort_by! { |r| [ r.send(sort_method), r.sortable_name ] }
        @project_resources.reverse! if @sort_order.downcase == 'desc'
      end

      @project_resources = Kaminari.paginate_array(@project_resources).page(params[:page]).per(6)

      respond_to do |format|
        format.html
        format.js
      end

    end

    private

    def load_project_resource
      project = services_ng.resource_management.find_project(
        @scoped_domain_id, params.require(:id),
        service: [ params.require(:service) ],
        resource: [ params.require(:resource) ],
      ) or raise ActiveRecord::RecordNotFound, "project #{params[:project]} not found"
      @project_resource = project.resources.first or raise ActiveRecord::RecordNotFound, "resource not found"
    end

    def load_domain_resource
      enforce_permissions(":resource_management:domain_admin_list")
      @resource = services_ng.resource_management.find_domain(
        @scoped_domain_id,
        service: Array.wrap(params.require(:service)),
        resource: Array.wrap(params.require(:resource)),
      ).resources.first or raise ActiveRecord::RecordNotFound
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

      @project_resource = services_ng.resource_management.find_project(
        @scoped_domain_id, @inquiry.project_id,
        service:  [ data[:service]  ],
        resource: [ data[:resource] ],
      ).resources.first or raise ActiveRecord::RecordNotFound

      @domain_resource = services_ng.resource_management.find_domain(
        @scoped_domain_id,
        service:  [ data[:service]  ],
        resource: [ data[:resource] ],
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
    end

  end
end
