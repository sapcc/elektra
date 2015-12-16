require_dependency "resource_management/application_controller"

module ResourceManagement
  class DomainAdminController < ApplicationController
    before_filter :set_usage_stage, :only => [:index,:show_area]

    def index
      @area_services = []
      ResourceManagement::Resource::KNOWN_SERVICES.each do |service_config|
        @area_services << service_config[:service]
      end
      
      @domain_quotas = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :project_id => nil, :service => @area_services)
      get_resource_status(true)
    end

    def show_area
      @area = params.require(:area).to_sym
      # which services belong to this area?
      @area_services = ResourceManagement::Resource::KNOWN_SERVICES.select { |srv| srv[:area] == @area }.map { |srv| srv[:service] }
      pp @area_services
      # load domain quota for these services
      @domain_quotas = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :project_id => nil, :service => @area_services)
      # load quota and usage for all projects within these domain
      get_resource_status()
    end

    def edit
      @project = params[:project]
      @value = params[:value]
    end

    def update
      @project  = params.require(:project)
      @service  = params.require(:service)
      @resource = params.require(:resource)

      # load Resource record for project
      @project_record = ResourceManagement::Resource.where(
        domain_id:  @scoped_domain_id,
        project_id: @project,
        service:    @service,
        name:       @resource,
      ).first
      data_type = @project_record.attributes[:data_type]

      # validate new quota value
      value = params.require(:new_value)
      begin
        value = view_context.parse_usage_or_quota_value(value, data_type)
        raise ArgumentError, 'new quota may not be lower than current usage' if value < @project_record.usage
      rescue ArgumentError => e
        render text: e.message, status: :bad_request
        return
      end

      @project_record.approved_quota = value
      @project_record.current_quota  = value
      services.resource_management.apply_current_quota(@project_record) # apply quota in target service
      @project_record.save

      # prepare the data for rendering
      @project   = @project_record.project_id
      @new_value = view_context.format_usage_or_quota_value(value, data_type) # TODO: this should be done in the view

      # get new data to render the usage partial
      @area_services = [ @service.to_sym ]
      @domain_quotas = ResourceManagement::Resource.where(
          domain_id:  @scoped_domain_id,
          project_id: nil,
          service:    @service,
          name:       @resource,
      )
      get_resource_status(false, @resource, true)

      respond_to do |format|
        format.js
      end
    end

    def resource_request
      @resource = params[:resource]
      @service = params[:service]
    end

    def details

      @page     = params[:page] || 1
      @resource = params.require(:resource)
      @service  = params.require(:service)
      @area_services = [@service.to_sym]
      @show_all_button = true if params[:overview].eql?("true")

      @domain_quotas = ResourceManagement::Resource.where(
          :domain_id  => @scoped_domain_id, 
          :project_id => nil, 
          :service    => @service.to_sym, 
          :name       => @resource.to_sym)
      
      if @domain_quotas.length > 0
        @area = @domain_quotas[0].attributes[:area]
      else
        # fallback if no quota was found (that should not happen)
        service_cfg = ResourceManagement::Resource::KNOWN_SERVICES. find{ |s| s[:service] == @service.to_sym }
        @area = service_cfg[:area] 
      end
      
      get_resource_status(false, @resource, true)

      respond_to do |format|
        format.html 
        format.js
      end
 
    end

    def sync_now
      services.resource_management.sync_projects(@scoped_domain_id, sync_all_projects: true) # TODO: this method should be called sync_domain()
      begin
        redirect_to :back
      rescue ActionController::RedirectBackError
        redirect_to admin_url()
      end
    end

    private
    # http://stackoverflow.com/questions/4589968/ruby-rails-how-to-check-if-a-var-is-an-integer
    def is_numeric?(obj) 
       obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
    end
 
    def set_usage_stage
      @usage_stage = { :danger => 1.0, :warning => 0.8 }
    end

    def get_resource_status(critical = false, resource = nil, render_projects = false)

      # get data for currently existing quotas
      quotas = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :service => @area_services)
      # get only the quotas for one resource
      if resource 
          quotas = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :service => @area_services, :name => resource)
      end
      stats = quotas.where.not(project_id: nil).
                     group("service,name").
                     pluck("service,name,SUM(GREATEST(current_quota,0)),SUM(usage)")
      
      # this is used for details view
      projects_data = quotas.where.not(project_id: nil)
      @projects = projects_data.page(@page).per(6) if render_projects
      # get min and max update of all quotas (for one resource or all)
      @min_updated_at, @max_updated_at = projects_data.pluck("MIN(updated_at), MAX(updated_at)").first

      # get unlimited quotas
      unlimited = ResourceManagement::Resource.
          where(:domain_id => @scoped_domain_id, :service => @area_services).
          where.not(project_id: nil).
          where(:current_quota => -1) 

      @resource_status = {}
      stats.each do |stat|
        service, name, current_project_quota_sum, usage_project_sum = *stat
        domain_service_quota = @domain_quotas.find { |q| q.service == service && q.name == name }
        # search for unlimited current quotas
        unlimited_project_quota_found = unlimited.find{|q| q.service == service && q.name == name}
       
        active_project_quota = unlimited_project_quota_found.nil?
        # when no domain quota exists yet, use an empty mock object
        domain_service_quota ||= ResourceManagement::Resource.new(
          service: service, name: name, approved_quota: -1,
        )

        # filter critical quotas
        if critical
          next if current_project_quota_sum < domain_service_quota.approved_quota and active_project_quota
        end
 
        @resource_status[service.to_sym] ||= []
        @resource_status[service.to_sym] << { 
          :name                      => name,
          :current_project_quota_sum => current_project_quota_sum,
          :usage_project_sum         => usage_project_sum,
          :active_project_quota      => active_project_quota,
          :domain_quota              => domain_service_quota,
        } 
      end
    end
  end
end
