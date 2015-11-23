module ResourceManagement
  class ApplicationController < DashboardController

    before_filter :set_usage_stage, :only => [:index,:show_area]

    def index
      # resources are critical if they have a quota, and either one of the quotas is 95% used up
      @resources = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :project_id => @scoped_project_id).
        where("(current_quota > 0 AND approved_quota > 0) AND (usage > #{@usage_stage[:danger]} * approved_quota OR usage > #{@usage_stage[:danger]} * current_quota)")
    end

    def resource_request
      @resource_type = params[:resource_type]
      @service = params[:service]
    end

    def show_area
      @area = params.require(:area).to_sym
      # which services belong to this area?
      @area_services = ResourceManagement::Resource::KNOWN_RESOURCES.select { |res| res[:area] == @area }.map { |res| res[:service] }.uniq
      # load all resources for these services
      @resources = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :project_id => @scoped_project_id, :service => @area_services)
    end

    def manual_sync
      service = services.resource_management
      service.sync_domains
      ResourceManagement::Resource.pluck('DISTINCT domain_id, project_id').each { |d,p| service.sync_project(d,p) }
      begin
        redirect_to :back
      rescue ActionController::RedirectBackError
        render text: "Synced!"
      end
    end

    private

    def set_usage_stage
      @usage_stage = { :danger => 0.95, :warning => 0.8 }
    end

  end
end
