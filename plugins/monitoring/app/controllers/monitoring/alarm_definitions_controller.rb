module Monitoring
  class AlarmDefinitionsController < Monitoring::ApplicationController
    authorization_required
    
    before_filter :load_alarm_definition, except: [ :index, :new, :create, :search ] 

    def index
      alarm_definitions = services.monitoring.alarm_definitions
      @alarm_definitions = Kaminari.paginate_array(alarm_definitions).page(params[:page]).per(10)
    end

    def search
       search = params[:search]
       alarm_definitions = services.monitoring.alarm_definitions(search)
       @alarm_definitions = Kaminari.paginate_array(alarm_definitions).page(params[:page]).per(10)
       respond_to do |format|
         format.js do
           render action: 'search_results'
         end
       end
    end

    def show
      notification_methods = services.monitoring.notification_methods
      @notification_methods_hash = {}
      notification_methods.each{|notification_method| @notification_methods_hash[notification_method.id] = notification_method }
    end

    def edit
    end

    def new
      @alarm_definition = services.monitoring.new_alarm_definition(name: "")
      @notification_methods = services.monitoring.notification_methods.sort_by(&:name)
    end

    def create
      @alarm_definition = services.monitoring.new_alarm_definition(params.require(:alarm_definition))
      unless @alarm_definition.save
        @notification_methods = services.monitoring.notification_methods.sort_by(&:name)
        render action: 'new'
        return
      end
      back_to_alarm_definition_list
    end

    def update
      attrs = params.require(:alarm_definition).permit(:name, :description, :expression, :severity, :match_by)
      unless @alarm_definition.update_attributes(attrs)
        render action: 'edit'
        return
      end
      back_to_alarm_definition_list
    end


    def destroy 
       @alarm_definition.destroy
       back_to_alarm_definition_list
    end

    private

    def back_to_alarm_definition_list
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
