module Monitoring
  class AlarmDefinitionsController < DashboardController
    authorization_context 'monitoring'

    def index
       @alarm_definitions = services.monitoring.alarm_definitions
    end

    def show
       @alarm_definition = services.monitoring.get_alarm_definition(params.require(:id))
    end

    def destroy 
       @alarm_definition = services.monitoring.get_alarm_definition(params.require(:id))
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

  end
end
