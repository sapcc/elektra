module ResourceManagement
  class ApplicationController < DashboardController
    def index
    end

    def details
      @resource_type = params[:resource_type]
      @level = params[:level]
    end

    def resource_request
      @resource_type = params[:resource_type]
      @level = params[:level]
    end
  end
end
