require_dependency "resource_management/application_controller"

module ResourceManagement
  class ProjectResourcesController < ::ResourceManagement::ApplicationController

    before_filter :load_project_resource, only: [:new_request, :create_request, :reduce_quota]
    before_filter :check_first_visit,     only: [:index, :show_area, :create_package_request]

    authorization_required

    def index
      @index = true
      
      @all_resources = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :project_id => @scoped_project_id).where.not(service: 'resource_management')
      # data age display should use @all_resources which we looked at, even those that do not appear to be critical right now
      @min_updated_at, @max_updated_at = @all_resources.pluck("MIN(updated_at), MAX(updated_at)").first

      # resources are critical if the usage exceeds the approved quota
      @critical_resources = @all_resources.where("usage > approved_quota").to_a
      # warn about resources where current_quota was set to exceed the approved value
      @warning_resources = @all_resources.where("usage <= approved_quota AND current_quota > approved_quota").to_a
      # also warn about resources where usage approaches the current_quota
      @nearly_full_resources = @all_resources.where("usage <= approved_quota AND current_quota <= approved_quota AND usage >= 0.8 * approved_quota AND usage > 0").to_a
    end

    def reduce_quota
      # Note: this function is used in two ways
      # first show the reduce quota window
      # second: reduce the quota
      
      if params[:resource] 
        # reduce the quota
        value = params[:resource][:current_quota]
        
        if value.empty?
          @project_resource.add_validation_error(:current_quota, "empty value is invalid")
        else 
          begin
            # pre check value
            if @project_resource.approved_quota < @project_resource.data_type.parse(value) &&
               @project_resource.current_quota < @project_resource.data_type.parse(value)
              @project_resource.add_validation_error(:current_quota, "wrong value: because the reduced quota value of #{value} is higher than your current quota")
            elsif @project_resource.usage > @project_resource.data_type.parse(value)
              @project_resource.add_validation_error(:current_quota, "wrong value: it is now allowed to reduce the quota below your current usage")
            elsif @project_resource.approved_quota == @project_resource.data_type.parse(value) &&
                  @project_resource.current_quota == @project_resource.data_type.parse(value)
              @project_resource.add_validation_error(:current_quota, "wrong value: because the reduced quota value is the same as your current quota")
            else
              @project_resource.approved_quota = @project_resource.data_type.parse(value)
              @project_resource.current_quota = @project_resource.data_type.parse(value)
            end
          rescue ArgumentError => e
            @project_resource.add_validation_error(:current_quota, 'is invalid: ' + e.message)
          end
        end

        # save the new quota to the database
        if @project_resource.save
          # apply new quota in target service
          services.resource_management.apply_current_quota(@project_resource) 
          
          # load data to reload the bars in the main view
          # which services belong to this area?
          @area = @project_resource.config.service.area.to_s
          @area_services = ResourceManagement::ServiceConfig.in_area(@area).map(&:name)
    
          # load all resources for these services
          @resources = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :project_id => @scoped_project_id, :service => @area_services)
        else
          # reload the reduce quota window with error
          respond_to do |format|
            format.html do
              render action: 'reduce_quota'
            end
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
        service_user.list_scope_admins({domain_id: @scoped_domain_id}),
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

    def new_package_request
      # please do not delete
    end

    def create_package_request
      unless @can_request_package
        respond_to do |format|
          format.js { render inline: 'alert("Error: You may not request a quota package anymore.")' }
        end
      end

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
        service_user.list_scope_admins({domain_id: @scoped_domain_id}),
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

      unless inquiry.errors?
        # reload view to show the "Quota package requested" header
        respond_to do |format|
          format.js { render inline: 'Dashboard.hideModal();document.location.reload();' }
        end
      end
    end

    def show_area
      @area = params.require(:area).to_sym

      # which services belong to this area?
      @area_services = ResourceManagement::ServiceConfig.in_area(@area).map(&:name)
      raise ActiveRecord::RecordNotFound, "unknown area #{@area}" if @area_services.empty?
      # load all resources for these services
      @resources = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :project_id => @scoped_project_id, :service => @area_services)
      @min_updated_at, @max_updated_at = @resources.pluck("MIN(updated_at), MAX(updated_at)").first
    end

    def sync_now
      services.resource_management.sync_project(@scoped_domain_id, @scoped_project_id, @scoped_project_name)
      begin
        redirect_to :back
      rescue ActionController::RedirectBackError
        redirect_to resources_path()
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
      @can_request_package = ResourceManagement::Resource.
        where(domain_id: @scoped_domain_id, project_id: @scoped_project_id).
        maximum(:approved_quota) == 0
      @has_requested_package = Inquiry::Inquiry.
        where(domain_id: @scoped_domain_id, project_id: @scoped_project_id, kind: 'project_quota_package', aasm_state: 'open').
        count > 0
    end

  end
end
