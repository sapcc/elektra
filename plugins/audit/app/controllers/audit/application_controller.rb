module Audit
  class ApplicationController < DashboardController
    def index
      @events_endpoint = current_user.service_url('audit-data')
    end
  end
end
