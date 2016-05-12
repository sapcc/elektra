module Monitoring
  class AlarmsController < Monitoring::ApplicationController
    authorization_required

    def index
      all_alarms = services.monitoring.alarms
      @alarms_count = all_alarms.length
      alarm_definitions = services.monitoring.alarm_definitions
      # map alarm definitions for later use in view to have show more information  in the list
      @alarm_definitions = Hash[alarm_definitions.map{ |a| [a.id, a] }]
      @alarms = Kaminari.paginate_array(all_alarms).page(params[:page]).per(10)
    end

    def filter
      state = params[:state]
      severity = params[:severity]
      all_alarms = services.monitoring.alarms( { state: state, severity: severity } )
      @alarms_count = all_alarms.length
      alarm_definitions = services.monitoring.alarm_definitions
      @alarm_definitions = Hash[alarm_definitions.map{ |a| [a.id, a] }]
      @alarms = Kaminari.paginate_array(all_alarms).page(params[:page]).per(10)
    end

    def show
      @alarm = services.monitoring.get_alarm(params.require(:id))
      @alarm_name = params[:name] || ''
      raise ActiveRecord::RecordNotFound, "alarm with id #{params[:id]} not found" unless @alarm
    end

    def destroy 
      alarm = services.monitoring.get_alarm(params.require(:id))
      alarm.destroy
      back_to_alarm_list
    end

    private

    def back_to_alarm_list
      respond_to do |format|
        format.js do
          index
          render action: 'reload_list'
        end
        format.html { redirect_to plugin('monitoring').alarms_path() }
      end
    end

  end
end
