require_dependency "resource_management/application_controller"

module ResourceManagement
  class DomainAdminController < ApplicationController
    def index
    end

    def resource_request
      @resource_type = params[:resource_type]
      @level = params[:level]
    end

    def details
      @resource_type = params[:resource_type]
      @level = params[:level]
    end

  end
end
