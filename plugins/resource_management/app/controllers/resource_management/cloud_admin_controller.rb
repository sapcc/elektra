require_dependency "resource_management/application_controller"

module ResourceManagement
  class CloudAdminController < ApplicationController
    def details
      @resource_type = params[:resource_type]
      @level = params[:level]
    end
  end
end
