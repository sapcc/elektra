require_dependency "resource_management/application_controller"

module ResourceManagement
  class CloudAdminController < ApplicationController
    before_filter :set_usage_stage, :only => [:index,:show_area]

    def index
      # resources are critical if they have a quota, and either one of the quotas is 95% used up
      @resources = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id).
        where("(current_quota > 0 AND approved_quota > 0) AND (usage > #{@usage_stage[:danger]} * approved_quota OR usage > #{@usage_stage[:danger]} * current_quota)")
      raise
    end

    def details
      @resource_type = params[:resource_type]
      @level = params[:level]
    end
    private

    def set_usage_stage
      @usage_stage = { :danger => 0.95, :warning => 0.8 }
    end

  end
end
