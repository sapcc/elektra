module Identity
  class ApplicationController < ::DashboardController
    def index
      head :ok
    end
  end
end
