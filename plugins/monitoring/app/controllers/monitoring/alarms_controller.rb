module Monitoring
  class AlarmsController < Monitoring::ApplicationController
    authorization_required

    def index
      alarms = services.monitoring.alarms
      @alarms = Kaminari.paginate_array(alarms).page(params[:page]).per(10)
    end
  end
end
