module Swift
  class ApplicationController < DashboardController
    def index
      @containers = services.swift.containers
    end
  end
end
