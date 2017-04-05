require_dependency "resource_management/application_controller"

module ResourceManagement
  class ProjectResourcesController < ::ResourceManagement::ApplicationController

    before_filter :load_project_resource, only: [:new_request, :create_request, :reduce_quota, :confirm_reduce_quota]
    before_filter :check_first_visit,     only: [:index, :show_area, :create_package_request]

    authorization_required

    def index
      @project = services.resource_management.find_project(@scoped_domain_id, @scoped_project_id)
      @min_updated_at = @project.services.map(&:updated_at).min
      @max_updated_at = @project.services.map(&:updated_at).max

      # find resources to show
      resources = @project.services.map(&:resources).flatten
      @critical_resources    = resources.reject { |res| res.backend_quota.nil? }
      @nearly_full_resources = resources.select { |res| res.backend_quota.nil? && res.usage > 0 && res.usage > 0.8 * res.quota }

      @index = true
    end

    def show_area(area = nil)
      @area = area || params.require(:area).to_sym

      # which services belong to this area?
      @area_services = ResourceManagement::ServiceConfig.in_area(@area)
      raise ActiveRecord::RecordNotFound, "unknown area #{@area}" if @area_services.empty?

      # load all resources for these services
      @project = services.resource_management.find_project(@scoped_domain_id, @scoped_project_id, services: @area_services.map(&:catalog_type))
      @resources = @project.services.map(&:resources).flatten
      @min_updated_at = @project.services.map(&:updated_at).min
      @max_updated_at = @project.services.map(&:updated_at).max
    end

    def confirm_reduce_quota
      # please do not delete
    end

    def reduce_quota

      value = params[:resource][:current_quota]

      if value.empty?
        @project_resource.add_validation_error(:current_quota, "empty value is invalid")
      else
        begin
          parsed_value = @project_resource.data_type.parse(value)
          # pre check value
          if @project_resource.approved_quota < parsed_value &&
             @project_resource.current_quota < parsed_value
            @project_resource.add_validation_error(:current_quota, "wrong value: because the wanted quota value of #{value} is higher than your current quota")
          elsif @project_resource.usage > parsed_value
            @project_resource.add_validation_error(:current_quota, "wrong value: it is now allowed to reduce the quota below your current usage")
          elsif @project_resource.approved_quota == parsed_value &&
                @project_resource.current_quota == parsed_value
            @project_resource.add_validation_error(:current_quota, "wrong value: because the wanted quota value is the same as your current quota")
          else
            @project_resource.approved_quota = parsed_value
            @project_resource.current_quota = parsed_value
          end
        rescue ArgumentError => e
          @project_resource.add_validation_error(:current_quota, 'is invalid: ' + e.message)
        end
      end

      # save the new quota to the database
      if @project_resource.save
        # apply new quota in target service
        @services_with_error = services.resource_management.apply_current_quota(@project_resource)

        # load data to reload the bars in the main view
        show_area(@project_resource.config.service.area.to_s)
      else
        # reload the reduce quota window with error
        respond_to do |format|
          format.html do
            render action: 'confirm_reduce_quota'
          end
        end
      end

    end

    def new_request
      # please do not delete
    end

    def create_request
      old_value = @project_resource.approved_quota
      data_type = @project_resource.data_type
      new_value = params.require(:resource).require(:approved_quota)

      # parse and validate value
      begin
        new_value = data_type.parse(new_value)
        @project_resource.approved_quota = new_value
        # check that the value is higher the the old value
        if new_value <= old_value || data_type.format(new_value) == data_type.format(old_value)
          @project_resource.add_validation_error(:approved_quota, 'must be larger than current value')
        end
      rescue ArgumentError => e
        @project_resource.add_validation_error(:approved_quota, 'is invalid: ' + e.message)
      end
      # back to square one if validation failed
      unless @project_resource.validate
        @has_errors = true
        # prepare data for usage display
        render action: :new_request
        return
      end

      # now we can create the inquiry
      base_url    = plugin('resource_management').admin_area_path(area: @project_resource.config.service.area.to_s, domain_id: @scoped_domain_id, project_id: nil)
      overlay_url = plugin('resource_management').admin_review_request_path(project_id: nil)

      inquiry = services.inquiry.create_inquiry(
        'project_quota',
        "project #{@scoped_domain_name}/#{@scoped_project_name}: add #{@project_resource.data_type.format(new_value - old_value)} #{@project_resource.service}/#{@project_resource.name}",
        current_user,
        {
          resource_id: @project_resource.id,
          service: @project_resource.service,
          resource: @project_resource.name,
          desired_quota: new_value,
        },
        service_user.list_scope_resource_admins(domain_id: @scoped_domain_id),
        #service_user.list_scope_admins({domain_id: @scoped_domain_id}),
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
        prepare_data_for_details_view(@project_resource.service.to_sym, @project_resource.name.to_sym)
        render action: :new_request
        return
      end

      respond_to do |format|
        format.js
      end
    end

    def initial_sync
      # do the magic inital sync for the package request from project wizard
      synced = ResourceManagement::Resource.where(domain_id: @scoped_domain_id, project_id: @scoped_project_id).where.not(service: 'resource_management').size > 0
      unless synced
        sync_now(true)
      end
      render :nothing => true, :status => 200, :content_type => 'text/html'
    end

    def new_package_request
      # please do not delete
    end

    def create_package_request
      # validate input
      pkg = params[:package]
      unless ResourceManagement::PackageConfig::PACKAGES.include?(pkg)
        respond_to do |format|
          format.js { render inline: 'alert("Error: Invalid quota package name specified.")' }
        end
      end

      # create inquiry
      base_url = plugin('resource_management').admin_path(domain_id: @scoped_domain_name, project_id: nil)
      overlay_url = plugin('resource_management').admin_review_package_request_path(domain_id: @scoped_domain_name, project_id: nil)

      inquiry = services.inquiry.create_inquiry(
        'project_quota_package',
        "project #{@scoped_domain_name}/#{@scoped_project_name}: apply quota package #{pkg}",
        current_user,
        {
          project_id: @scoped_project_id,
          package:    pkg,
        },
        service_user.list_scope_resource_admins(domain_id: @scoped_domain_id),
        #service_user.list_scope_admins({domain_id: @scoped_domain_id}),
        {
          "approved": {
            "name": "Approve",
            "action": "#{base_url}?overlay=#{overlay_url}",
          },
        },
        nil,
        {
            domain_name: @scoped_domain_name,
            region: current_region,
        },
      )

      if inquiry.errors.empty?
        render template: '/resource_management/project_resources/create_package_request.js'
      else
        render action: :new_package_request
      end
    end

    def sync_now(direct = false)
      services.resource_management.sync_project(@scoped_domain_id, @scoped_project_id, @scoped_project_name)
      unless direct
        begin
          redirect_to :back
        rescue ActionController::RedirectBackError
          redirect_to resources_path()
        end
      end
    end

    private

    def load_project_resource
      @project_resource = ResourceManagement::Resource.find(params.require(:id))
      raise ActiveRecord::RecordNotFound if @project_resource.id.nil? or @project_resource.project_id.nil?
    end

    def check_first_visit
      # if no quota has been approved yet, the user may request an initial
      # package of quotas
      @show_package_request_banner = true
      ResourceManagement::Resource.where(domain_id: @scoped_domain_id, project_id: @scoped_project_id).where('approved_quota > 0').each do |res|
        auto = res.config.auto_approved_quota
        if res.approved_quota != auto or res.current_quota != auto or res.usage != auto
          @show_package_request_banner = false
        end
      end
      @has_requested_package = Inquiry::Inquiry.
        where(domain_id: @scoped_domain_id, project_id: @scoped_project_id, kind: 'project_quota_package', aasm_state: 'open').
        count > 0
    end

  end
end
