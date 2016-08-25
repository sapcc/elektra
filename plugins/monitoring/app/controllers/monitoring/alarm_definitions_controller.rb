module Monitoring
  class AlarmDefinitionsController < Monitoring::ApplicationController
    authorization_required
    
    before_filter :load_alarm_definition, except: [ :index, :new,:from_expression_wizzard_new, :create, :search, :create_expression, :get_dimensions_by_metric, :dimension_row, :statistics ] 

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
      @head = 'New Alarm Definition'
      @alarm_definition = services.monitoring.new_alarm_definition(name: "")
      @notification_methods = services.monitoring.notification_methods.sort_by(&:name)
    end
    
    def from_expression_wizzard_new
      @head = 'Create Alarm Definition'
      expression = params['expression'] || ''
      
      #dimensions = params['filter_by_dimensions']
      #@filter_by = filter_by_dimensions.to_json if dimensions || []
      
      @alarm_definition = services.monitoring.new_alarm_definition(name: "", expression: expression)
      @notification_methods = services.monitoring.notification_methods.sort_by(&:name)
      render action: 'new_with_expression'
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

    def statistics
      metric     = params.require('metric')
      dimensions = params['dimensions'] || ''
      period     = params.require('period')
      threshold  = params.require('threshold')
      statistical_function = params.require('statistical_function')
      
      columns = []
      if statistical_function == 'avg' || 
         statistical_function == 'min' ||
         statistical_function == 'max'
         statistical_function = 'avg,min,max'
         columns = ['avg','max','min','threshold']
      else
        columns << statistical_function
        columns << 'threshold'
      end

      # get the statistic data for the last 6 hours
      t = Time.now.utc - (60*120)
      statistics = services.monitoring.list_statistics({
        name: metric, 
        start_time: t.iso8601,
        statistics: statistical_function,
        dimensions: dimensions,
        period: period,
        merge_metrics: true
      })
      
      data = [];
      columns.each do |column|
        values = [];
        x = 0;
        statistics.statistics.each do |statistic|
          if column == 'threshold'
            values << {x: x, y: threshold}
          else
            values << {x: x, y: statistic[statistics.columns.find_index(column)]}
          end
          x +=period.to_i/60
        end
        data << {key: column, values: values}
      end
      
      render json: data
    end

    def toggle_alarm_actions
      attrs = { 
        actions_enabled: !@alarm_definition.actions_enabled,
      } 
      
      @alarm_definition.update_attributes(attrs)
    end
    
    def create_expression
      # chain expressions keep it vor later
      # expressions = params['expressions'] || ""
      @step_count = params['step_count'] || 1
      
      # chain expressions keep it vor later
      # split expression into subexpression parts
      # @sub_expressions = expressions.split(/(AND|OR)/).each_slice(2).to_a
      @metric_names = services.monitoring.get_metric_names
      
      # dummy data for testing
      #@metric_names = ['foo','bla']
    end
    
    def get_dimensions_by_metric
      name = params.require(:name)
      # get all dimensions 60 minutes ago
      t = Time.now.utc - (60*60)
      metrics = services.monitoring.get_metric({
        name: name, 
        start_time: t.iso8601
      })
      dimensions = Hash.new{ |h, k| h[k] = [] }
      metrics.map{ |metric| metric.dimensions.select{ |key, value| dimensions[key] << value }}
      dimensions[''] << ''
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
