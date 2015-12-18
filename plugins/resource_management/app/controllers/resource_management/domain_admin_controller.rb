require_dependency "resource_management/application_controller"

module ResourceManagement
  class DomainAdminController < ApplicationController

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
      # load domain quota for these services
      @domain_quotas = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :project_id => nil, :service => @area_services)
      # load quota and usage for all projects within these domain
      get_resource_status()
    end

    def edit
      @project_resource = ResourceManagement::Resource.find(params.require(:id))
      raise ActiveRecord::RecordNotFound if @project_resource.domain_id != @scoped_domain_id or @project_resource.project_id.nil?
    end

    def update
      # load Resource record to modify
      @project_resource = ResourceManagement::Resource.find(params.require(:id))
      raise ActiveRecord::RecordNotFound if @project_resource.domain_id != @scoped_domain_id or @project_resource.project_id.nil?

      # legacy @-variables (TODO: remove from views)
      @service  = @project_resource.service.to_sym

      # validate new quota value
      value = params.require(:value)
      begin
        value = view_context.parse_usage_or_quota_value(value, @project_resource.attributes[:data_type])
        raise ArgumentError, 'New quota may not be lower than current usage!' if value < @project_resource.usage
      rescue ArgumentError => e
        render text: e.message, status: :bad_request
        return
      end

      @project_resource.approved_quota = value
      @project_resource.current_quota  = value
      services.resource_management.apply_current_quota(@project_resource) # apply quota in target service
      @project_resource.save

      # prepare data for view
      prepare_data_for_details_view(@service, @project_resource.name.to_sym)

      respond_to do |format|
        format.js
      end
    end

    def resource_request
      @resource = params[:resource]
      @service = params[:service]
    end

    def details
      @show_all_button = true if params[:overview] == 'true'

      @service  = params.require(:service).to_sym
      @resource = params.require(:resource).to_sym
      @area     = ResourceManagement::Resource::KNOWN_SERVICES.find { |s| s[:service] == @service }[:area]

      # some parts of data collection are shared with update()
      project_resources = prepare_data_for_details_view(@service, @resource)

      # get mapping of project IDs to names
      @project_names = services.resource_management.driver.enumerate_projects(@scoped_domain_id)

      # prepare the projects table
      projects = project_resources.to_a.sort_by do |project_resource|
        # find project name
        project_id   = project_resource.project_id
        project_name = (@project_names[project_id] || project_id).downcase
        # find warning level for project
        warning_level = view_context.warning_level_for_project(project_resource)
        sort_order    = { "danger" => 0, "warning" => 1 }.fetch(warning_level, 2)
        # sort projects by warning level, then by name
        [ sort_order, project_name ]
      end
      @projects = Kaminari.paginate_array(projects).page(params[:page]).per(6)

      respond_to do |format|
        format.html 
        format.js
      end
 
    end

    def sync_now
      services.resource_management.sync_domain(@scoped_domain_id, with_projects: true)
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
 
    def get_resource_status(critical = false, resource = nil, render_projects = false)
      # TODO FIXME: refactor this method (there are too many concerns in here)

      # get data for currently existing quotas
      quotas = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :service => @area_services)
      stats = quotas.where.not(project_id: nil).
                     group("service,name").
                     pluck("service,name,SUM(GREATEST(current_quota,0)),SUM(usage)")
      
      # this is used for details view
      projects_data = quotas.where.not(project_id: nil)
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

    # Some data collection that's shared between the details() and update() actions.
    def prepare_data_for_details_view(service, resource)
      # load domain resource and corresponding project resources
      resources = ResourceManagement::Resource.
        where(domain_id: @scoped_domain_id, service: service, name: resource)

      domain_resource   = resources.where(project_id: nil).first
      project_resources = resources.where.not(project_id: nil)

      # when no domain resource record exists yet, use an empty mock object
      domain_resource ||= ResourceManagement::ResourceManagement.new(
        domain_id: @scoped_domain_id, service: service, name: resource, approved_quota: 0,
      )

      # statistics over project resources
      min_current_quota, current_quota_sum, usage_sum = project_resources.
        pluck("MIN(current_quota), SUM(GREATEST(current_quota,0)), SUM(usage)").first

      @resource_status = {
        service => [ # TODO: wonky structure
          {
            name:                      resource,
            current_project_quota_sum: current_quota_sum,
            usage_project_sum:         usage_sum,
            active_project_quota:      min_current_quota >= 0, # TODO: wonky name, should be inversed, then called "has_infinite_project_quota"
            domain_quota:              domain_resource,
          },
        ],
      }

      return project_resources # this is used for further data collection by details()
    end

  end
end
