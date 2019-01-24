require_dependency "resource_management/application_controller"

module ResourceManagement
  class ProjectResourcesController < ::ResourceManagement::ApplicationController

    before_action :load_project,          only: [:new_package_request, :settings, :save_settings, :skip_wizard_confirm, :skip_wizard]
    before_action :load_project_resource, only: [:new_request, :create_request, :reduce_quota, :confirm_reduce_quota]
    before_action :check_first_visit,     only: [:index, :show_area, :create_package_request]

    authorization_context 'resource_management'
    authorization_required

    def index
      @project = services.resource_management.find_project(@scoped_domain_id, @scoped_project_id)
      @view_services = @project.services

      # special case to poll elektra during sync now process
      if params.include?(:if_updated_since)
        min_updated_at = @view_services.map(&:updated_at).min
        render :json => { :sync_running => params[:if_updated_since].to_i > min_updated_at.to_time.to_i }
        return
      end

      # find resources to show
      resources = @project.resources
      @critical_resources    = resources.reject { |res| res.backend_quota.nil? }
      @nearly_full_resources = resources.select { |res| res.backend_quota.nil? && res.usage > 0 && res.usage > 0.8 * res.quota }

      @index = true
      @areas = @project.services.map(&:area).uniq
    end

    def show_area(area = nil)
      @area = area || params.require(:area).to_sym

      # load all resources for these services
      @project = services.resource_management.find_project(@scoped_domain_id, @scoped_project_id)
      @view_services = @project.services.select { |srv| srv.area.to_sym == @area }
      raise ActiveRecord::RecordNotFound, "unknown area #{@area}" if @view_services.empty?

      @areas = @project.services.map(&:area).uniq
    end

    def confirm_reduce_quota
      # please do not delete
    end

    def save_settings
      @project.bursting[:enabled] = params[:project][:bursting_enabled] == "true"
      unless @project.save
        respond_to do |format|
          format.html do
            render action: 'settings'
          end
        end
      end
    end

    def settings
      # please do not delete
    end

    def reduce_quota
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

      # save the new quota to the database
      if @resource.save
        # load data to reload the bars in the main view
        show_area(@resource.service_area)
        @reduce_resource_success = true
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
      old_value = @resource.quota
      data_type = @resource.data_type
      new_value = params.require(:new_style_resource).require(:quota)

      # parse and validate value
      begin
        new_value = data_type.parse(new_value)
        @resource.quota = new_value
        # check that the value is higher the the old value
        if new_value <= old_value || data_type.format(new_value) == data_type.format(old_value)
          @resource.add_validation_error(:quota, 'must be larger than current value')
        end
      rescue ArgumentError => e
        @resource.add_validation_error(:quota, 'is invalid: ' + e.message)
      end
      # back to square one if validation failed
      unless @resource.validate
        # prepare data for usage display
        render action: :new_request
        return
      end

      # try to auto-approve
      if @resource.save
        @auto_approve_success = true
      else
        # if auto-aprove failed create the inquiry
        base_url    = plugin('resource_management').admin_area_path(area: @resource.service_area.to_s, domain_id: @scoped_domain_id, project_id: nil)
        overlay_url = plugin('resource_management').admin_review_request_path(project_id: nil)

        @inquiry = services.inquiry.create_inquiry(
          'project_quota',
          "project #{@scoped_domain_name}/#{@scoped_project_name}: add #{@resource.data_type.format(new_value - old_value)} #{@resource.service_type}/#{@resource.name}",
          current_user,
          {
            service: @resource.service_type,
            resource: @resource.name,
            desired_quota: new_value,
          },
          service_user.identity.list_scope_resource_admins(domain_id: @scoped_domain_id),
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
        if @inquiry.errors?
          render action: :new_request
          return
        else
          @send_resource_request = true
        end
      end

      # load data to reload the bars in the main view
      show_area(@resource.service_area)

      respond_to do |format|
        format.js
      end

    end

    def new_package_request
      # please do not delete
    end

    def create_package_request
      # validate input
      pkg = ResourceManagement::Package.find(params[:package])
      unless pkg
        respond_to do |format|
          format.js { render inline: 'alert("Error: Invalid quota package name specified.")' }
        end
        return
      end

      # create inquiry
      base_url = plugin('resource_management').admin_path(domain_id: @scoped_domain_name, project_id: nil)
      overlay_url = plugin('resource_management').admin_review_package_request_path(domain_id: @scoped_domain_name, project_id: nil)

      inquiry = services.inquiry.create_inquiry(
        'project_quota_package',
        "project #{@scoped_domain_name}/#{@scoped_project_name}: apply quota package #{pkg.key}",
        current_user,
        { package: pkg.key },
        service_user.identity.list_scope_resource_admins(domain_id: @scoped_domain_id),
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

    def sync_now
      services.resource_management.sync_project_asynchronously(
        @scoped_domain_id, @scoped_project_id
      )
      @start_time = Time.now.to_i
    end

    def skip_wizard_confirm
      # placeholder
    end

    def skip_wizard
      skip_wizard = params[:project][:skip_wizard] == "1" || false
      project_profile = ProjectProfile.find_or_create_by_project_id(@scoped_project_id)
      if skip_wizard
        project_profile.update_wizard_status('resource_management',ProjectProfile::STATUS_DONE)
      end
    end

    private

    def load_project
      @project = services.resource_management.find_project(
        @scoped_domain_id, @scoped_project_id
      ) || raise(ActiveRecord::RecordNotFound)
    end

    def load_project_resource
      @resource = services.resource_management.find_project(
        @scoped_domain_id, @scoped_project_id,
        service: Array.wrap(params.require(:service)),
        resource: Array.wrap(params.require(:resource)),
      ).resources.first or raise ActiveRecord::RecordNotFound
    end

    def check_first_visit
      enforce_permissions("resource_management:project_resource_list")
      # if no quota has been approved yet, the user may request an initial
      # package of quotas
      @show_package_request_banner = ! services.resource_management.has_project_quotas?(current_user.domain_id,current_user.project_id,current_user.project_domain_id)
      @has_requested_package = Inquiry::Inquiry.
        where(domain_id: @scoped_domain_id, project_id: @scoped_project_id, kind: 'project_quota_package', aasm_state: 'open').
        count > 0
    end

  end
end
