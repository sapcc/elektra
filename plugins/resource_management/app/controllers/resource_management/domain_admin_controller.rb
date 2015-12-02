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


    def resource_request
      @resource = params[:resource]
      @service = params[:service]
    end

    def details
      @resource = params[:resource]
      @service = params[:service]
      @area_services = [@service.to_sym]
      @show_all_button = true if params[:overview].eql?("true")

      @domain_quotas = ResourceManagement::Resource.where(
          :domain_id => @scoped_domain_id, 
          :project_id => nil, 
          :service => @service.to_sym, 
          :name => @resource.to_sym)
      
      get_resource_status(false, @resource, true)
    end

    private

    def set_usage_stage
      @usage_stage = { :danger => 1.0, :warning => 0.8 }
    end

    def get_resource_status(critical = false, resource = nil, projects = false)

      # get data for currently existing quota
      quotas = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :service => @area_services)
      # get only the quotas for one resource
      if resource 
          quotas = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :service => @area_services, :name => resource)
      end
      stats = quotas.where.not(project_id: nil).
                     group("service,name").
                     pluck("service,name,SUM(current_quota),SUM(usage)")
      
      # this is used for details view
      @projects = quotas.where.not(project_id: nil) if projects

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
       
        active_project_quota = false
        if unlimited_project_quota_found.nil?
          active_project_quota = true
        else
          # increment because we lost -1 in the quota summary
          current_project_quota_sum = current_project_quota_sum += 1 
        end
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
          :name => name,
          :current_project_quota_sum => current_project_quota_sum,
          :usage_project_sum => usage_project_sum,
          :active_project_quota => active_project_quota,
          :domain_quota => domain_service_quota,
        } 
      end
    end
  end
end
