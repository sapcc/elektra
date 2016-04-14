module Monitoring
  class AlarmDefinitionsController < Monitoring::ApplicationController
    authorization_context 'monitoring'
    before_filter :load_alarm_definition, except: [ :index, :new, :create ] 

    def index
      alarm_definitions = services.monitoring.alarm_definitions
      sorted_alarm_definitions = []
      # sort by name
      alarm_definitions.sort_by(&:name).each do |alarm_definition|
        sorted_alarm_definitions << alarm_definition
      end

      @alarm_definitions = Kaminari.paginate_array(sorted_alarm_definitions).page(params[:page]).per(10)
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
          render action: 'reload_list'
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
