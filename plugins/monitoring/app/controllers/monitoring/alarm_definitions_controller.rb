module Monitoring
  class AlarmDefinitionsController < DashboardController
    authorization_context 'monitoring'
    before_filter :load_alarm_definition, except: [ :index, :new, :create ] 

    def index
       @alarm_definitions = services.monitoring.alarm_definitions
    end

    def show
    end

    def destroy 
       @alarm_definition.destroy
       back_to_definition_list
    end

    private

    def back_to_definition_list
      respond_to do |format|
        format.js do
          @alarm_definitions = services.monitoring.alarm_definitions
          render action: 'reload_definitions_list'
        end
        format.html { redirect_to plugin('monitoring').alarm_definitions_path }
      end
    end

    def load_alarm_definition
      @alarm_definition = services.monitoring.get_alarm_definition(params.require(:id))
      raise ActiveRecord::RecordNotFound, "alarm definition with id #{params[:id]} not found" unless @alarm_definition
    end

  end
end
