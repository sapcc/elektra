module Monitoring
  class AlarmsController < Monitoring::ApplicationController
    authorization_required

    before_filter :load_alarm, except: [ :index, :filter_and_search ]

    def index
      @context = "alarms"
      @index = 1
      
      # set default if nothing was given
      @state = params[:state] || cookies[:filter_alarm_state] || 'Alarm'
      @severity = params[:severity] || cookies[:filter_alarm_severity] || 'All'
      
      # note: take a look to _filter partial
    end

    def filter_and_search
      @search = params[:search] || cookies[:alarms_search] || ''
      query = {
        search: @search,
      }.reject { |k,v| v.blank? }
      
      state    = params[:state] || cookies[:filter_alarm_state]
      severity = params[:severity] || cookies[:filter_alarm_severity]
      
      query[:state]    = state.upcase if state and state != 'All'
      query[:severity] = severity.upcase if severity and severity != 'All'

      all_alarms = services.monitoring.alarms(query)
      @alarms_count = all_alarms.length
      alarm_definitions = services.monitoring.alarm_definitions
      @alarm_definitions = Hash[alarm_definitions.map{ |a| [a.id, a] }]
      @alarms = Kaminari.paginate_array(all_alarms).page(params[:page]).per(10)
      render action: 'reload_list'
    end

    def show
      # to get only the latest 5 change
      history(5,5)
    end

    def history(paginate = 7,limit = 20)
      # TODO: maybe we should use later here the option limit?
      #       or to limit we should get only all alarm changes since the last 7 days
      #       and give the user a selection to choose the time window
      #       a search field is maybe a good idea too
      # https://github.com/openstack/monasca-api/blob/master/docs/monasca-api-spec.md#list-alarm-state-history
      id = params[:id] || params.require(:alarm_id)
      # TODO: latest first!
      states = services.monitoring.alarm_states_history(id,{limit: limit}).sort_by(&:timestamp).reverse
      @alarm_states_count = states.length
      @alarm_states = Kaminari.paginate_array(states).page(params[:page]).per(paginate)
    end

    def destroy
      @alarm.destroy
      back_to_alarm_list
    end

    private

    def back_to_alarm_list
      # only load the alarm list
      respond_to do |format|
        format.js do
          index
          render action: 'reload_list'
        end
        # render index site
        format.html { redirect_to plugin('monitoring').alarms_path() }
      end
    end

    def load_alarm
      id = params[:id] || params.require(:alarm_id)
      @alarm = services.monitoring.get_alarm(id)
      # @alarm is loaded before destoy so we only need to take care in one place
      raise ActiveRecord::RecordNotFound, "The alarm with id #{params[:id]} was not found.  Maybe it was deleted from someone else?" unless @alarm.try(:id)
      
      @alarm_name = params[:name] || ''
    end

  end
end
