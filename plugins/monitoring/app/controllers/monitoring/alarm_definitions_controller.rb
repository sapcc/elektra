module Monitoring
  class AlarmDefinitionsController < DashboardController
    authorization_context 'monitoring'

    def index
       @alarm_definitions = services.monitoring.alarm_definitions
    end

    def show
       @alarm_definition = services.monitoring.get_alarm_definition(params.require(:id))
    end
  end
end
