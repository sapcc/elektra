module Monitoring
  class AlarmDefinitionsController < Monitoring::ApplicationController
    authorization_required
    
    before_filter :load_alarm_definition, except: [ :index, :new, :create, :search, :create_expression, :get_dimensions_by_metric, :dimension_row ] 

    def index
      all_alarm_definitions = services.monitoring.alarm_definitions
      @alarm_definitions_count = all_alarm_definitions.length
      @alarm_definitions = Kaminari.paginate_array(all_alarm_definitions).page(params[:page]).per(10)
    end

    def search
      @search = params[:search]
      searched_alarm_definitions = services.monitoring.alarm_definitions(@search)
      @alarm_definitions_count = searched_alarm_definitions.length
      @alarm_definitions = Kaminari.paginate_array(searched_alarm_definitions).page(params[:page]).per(10)
      render action: 'index'
    end

    def show
      notification_methods = services.monitoring.notification_methods
      @notification_methods_hash = {}
      notification_methods.each{|notification_method| @notification_methods_hash[notification_method.id] = notification_method }
    end

    def edit
      @notification_methods = services.monitoring.notification_methods.sort_by(&:name)
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
      attrs = params.require(:alarm_definition).permit(
        :name, 
        :description, 
        :expression, 
        :severity, 
        :match_by, 
        :actions_enabled, 
        # http://stackoverflow.com/questions/16549382/how-to-permit-an-array-with-strong-parameters
        # To declare that the value in params must be an array of permitted scalar values map the key to an empty array
        { ok_actions: [] },
        { alarm_actions: [] },
        { undetermined_actions: [] },
      ) 

      unless @alarm_definition.update_attributes(attrs)
        @notification_methods = services.monitoring.notification_methods.sort_by(&:name)
        render action: 'edit'
        return
      end
      back_to_alarm_definition_list
    end

    def destroy 
       @alarm_definition.destroy
       back_to_alarm_definition_list
    end

    def toggle_alarm_actions
      attrs = { 
        actions_enabled: !@alarm_definition.actions_enabled,
      } 
      
      @alarm_definition.update_attributes(attrs)
    end
    
    def create_expression
      @metric_names = services.monitoring.get_metric_names
    end
    
    def get_dimensions_by_metric
      name = params.require(:name)
      t = Time.now.utc - (60*60)
      metrics = services.monitoring.get_metric({name: name, start_time: t.iso8601})
      dimensions = Hash.new{ |h, k| h[k] = [] } 
      metrics.map{ |metric| metric.dimensions.select{ |key, value| dimensions[key] << value }}
      render json: dimensions
    end

    def dimension_row
      @cnt = params.require(:cnt).to_i
      @keys = JSON.parse(params.require(:keys));
      @next = @cnt + 1
      render partial: "dimension_row"
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
