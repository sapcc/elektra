module ResourceManagement
  class ApplicationController < DashboardController
    def index
    end

    def details
      @resource_type = params[:resource_type]
      @level = params[:level]
      puts modal?
    end
  end
end
