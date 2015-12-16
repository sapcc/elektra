require_dependency "resource_management/application_controller"

module ResourceManagement
  class ProjectResourcesController < ApplicationController

    before_filter :set_usage_stage, :only => [:index,:show_area]

    def index
      @all_resources = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :project_id => @scoped_project_id)
      # data age display should use @all_resources which we looked at, even those that do not appear to be critical right now
      @min_updated_at, @max_updated_at = @all_resources.pluck("MIN(updated_at), MAX(updated_at)").first
      # resources are critical if they have a quota, and either one of the quotas is 95% used up
      @resources = @all_resources.where("((current_quota = -1 OR current_quota > 0) AND approved_quota >= 0) AND (usage > #{@usage_stage[:danger]} * approved_quota OR usage > #{@usage_stage[:danger]} * current_quota)")
    end

    def resource_request
      @resource = params.require(:resource)
      @service = params.require(:service)
    end

    def show_area
      @area = params.require(:area).to_sym

      # which services belong to this area?
      @area_services = ResourceManagement::Resource::KNOWN_SERVICES.select { |srv| srv[:area] == @area && srv[:enabled] }.map { |srv| srv[:service] }
      raise ActiveRecord::RecordNotFound, "unknown area #{@area}" if @area_services.empty?

      # load all resources for these services
      @resources = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :project_id => @scoped_project_id, :service => @area_services)
      @min_updated_at, @max_updated_at = @resources.pluck("MIN(updated_at), MAX(updated_at)").first
    end

    def sync_now
      services.resource_management.sync_project(@scoped_domain_id, @scoped_project_id)
      begin
        redirect_to :back
      rescue ActionController::RedirectBackError
        redirect_to resources_url()
      end
    end

    def manual_sync
      service = services.resource_management
      service.sync_all_domains(with_projects: true)
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
