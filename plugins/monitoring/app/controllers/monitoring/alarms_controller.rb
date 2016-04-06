module Monitoring
  class AlarmsController < DashboardController
    authorization_context 'monitoring'

    def index
    end
  end
end
