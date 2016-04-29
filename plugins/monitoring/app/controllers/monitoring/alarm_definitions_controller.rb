module Monitoring
  class AlarmDefinitionsController < Monitoring::ApplicationController
    authorization_context 'monitoring'
    before_filter :load_alarm_definition, except: [ :index, :new, :create, :filter ] 

    def index
      alarm_definitions = services.monitoring.alarm_definitions
      @alarm_definitions = Kaminari.paginate_array(alarm_definitions).page(params[:page]).per(10)
    end

    def filter
       filter = params[:filter]
       alarm_definitions = services.monitoring.alarm_definitions(filter)
       @alarm_definitions = Kaminari.paginate_array(alarm_definitions).page(params[:page]).per(10)
       respond_to do |format|
         format.js do
           render action: 'filter'
         end
       end
    end

    def show
    end

    def edit
    end

    def new
    end

    def create
    end

    def destroy 
       @alarm_definition.destroy
       back_to_definition_list
    end

    private

    def back_to_definition_list
      respond_to do |format|
        format.js do
          index
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
