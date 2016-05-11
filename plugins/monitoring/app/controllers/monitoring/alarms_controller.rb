module Monitoring
  class AlarmsController < Monitoring::ApplicationController
    authorization_required

    def index
      alarms = services.monitoring.alarms
      alarm_definitions = services.monitoring.alarm_definitions
      # map alarm definitions for later use in view to have show more information  in the list
      @alarm_definitions = Hash[alarm_definitions.map{ |a| [a.id, a] }]
      @alarms = Kaminari.paginate_array(alarms).page(params[:page]).per(10)
    end

    def filter
      alarms = services.monitoring.alarms
      @alarms = Kaminari.paginate_array(alarms).page(params[:page]).per(10)
    end
  end
end
