module Monitoring
  class AlarmsController < DashboardController
    authorization_context 'monitoring'

    def index
      alarms = services.monitoring.alarms
#      sorted_alarms = []
#      # sort by name
#      alarm_definitions.sort_by(&:name).each do |alarm_definition|
#        sorted_alarm_definitions << alarm_definition
#      end

      @alarms = Kaminari.paginate_array(alarms).page(params[:page]).per(10)
    end
  end
end
