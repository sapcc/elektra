module Monitoring
  class ApplicationController < DashboardController
    authorization_context 'monitoring'

    def index
       @alarm_definitions = services.monitoring.alarm_definitions
    end
  end
end
