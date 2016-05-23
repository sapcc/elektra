module Monitoring
  class AlarmsController < Monitoring::ApplicationController
    authorization_required

    before_filter :load_alarm, except: [ :index, :filter_and_search ]

    def index
      @index = 1
    end

    def filter_and_search
      state = params[:state]
      severity = params[:severity]
      @search = params[:search]
      all_alarms = services.monitoring.alarms(state: state, severity: severity, search: @search)
      @alarms_count = all_alarms.length
      alarm_definitions = services.monitoring.alarm_definitions
      @alarm_definitions = Hash[alarm_definitions.map{ |a| [a.id, a] }]
      @alarms = Kaminari.paginate_array(all_alarms).page(params[:page]).per(10)
      render action: 'reload_list'
    end

    def show
    end

    def destroy
      @alarm.destroy
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

    def load_alarm
      @alarm = services.monitoring.get_alarm(params.require(:id))
      @alarm_name = params[:name] || ''
      raise ActiveRecord::RecordNotFound, "alarm with id #{params[:id]} not found" unless @alarm
    end

  end
end
