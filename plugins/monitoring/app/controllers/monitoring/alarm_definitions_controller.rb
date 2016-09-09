module Monitoring
  class AlarmDefinitionsController < Monitoring::ApplicationController
    authorization_required
    
    before_filter :load_alarm_definition, except: [ 
      :index, 
      :new,
      :from_expression_wizzard_new,
      :create,
      :search,
      :create_expression,
      :get_dimensions_for_metric,
      :dimension_row,
      :statistics,
      :edit_expression
    ]
    
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
      parse_expression(@alarm_definition.expression)
    end

    def edit
      @expression = @alarm_definition.expression
      @notification_methods = services.monitoring.notification_methods.sort_by(&:name)
    end

    def new
      @head = 'New Alarm Definition'
      @alarm_definition = services.monitoring.new_alarm_definition(name: "")
      @notification_methods = services.monitoring.notification_methods.sort_by(&:name)
    end
    
    # this is used when the generated expression is transfered to the create alarm definitions view
    def from_expression_wizzard_new
      @head = 'Create Alarm Definition'
      expression = params['expression'] || ''
      
      filter_by_dimensions = params['filter_by_dimensions']
      @filter_by = filter_by_dimensions.split(/,/) if filter_by_dimensions || []
      
      @alarm_definition = services.monitoring.new_alarm_definition(name: "", expression: expression)
      @notification_methods = services.monitoring.notification_methods.sort_by(&:name)
      render action: 'new_with_expression'
    end

    # this is used when the modified expression is transfered to the edit alarm definitions view
    def from_expression_wizzard_edit
      expression = params[:expression]
      if expression 
        @alarm_definition.expression = expression
      end
      @notification_methods = services.monitoring.notification_methods.sort_by(&:name)
      render action: 'edit_with_expression'
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

    # get statistics for given expression
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

      # get the statistic data for the last 120 minutes
      t = Time.now.utc - (60*120)
      statistics = services.monitoring.list_statistics({
        name: metric, 
        start_time: t.iso8601,
        statistics: statistical_function,
        dimensions: dimensions.gsub(/=/,':'),
        period: period,
        merge_metrics: true
      })
      
      data = [];
      columns.each do |column|
        values = [];
        x = 0;
        if statistics
          statistics.statistics.each do |statistic|
            if column == 'threshold'
              values << {x: x, y: threshold}
            else
              current_value = statistic[statistics.columns.find_index(column)]
              # round values
              current_value = current_value.round(2) if current_value.is_a? Numeric
              values << {x: x, y: current_value}
            end
            x +=period.to_i/60
          end
          data << {key: column, values: values}
        end
      end

      render json: data
    end

    def toggle_alarm_actions
      attrs = { 
        actions_enabled: !@alarm_definition.actions_enabled,
      } 
      
      @alarm_definition.update_attributes(attrs)
    end
    
    # edit a predefined expression
    # it is only allowed to change statistical functions, period and threshold
    def edit_expression
      @expression = params.require(:expression)
      @alarm_definition_id = params.require(:alarm_definition_id)
      @after_login = plugin('monitoring').alarm_definitions_path();
      parse_expression(@expression)
    end
    
    # create a new expression from scratch
    def create_expression
      # chain expressions keep it vor later
      # expressions = params['expressions'] || ""
      @step_count = params['step_count'] || 1
      @after_login = plugin('monitoring').alarm_definitions_path(overlay: 'create_expression')
      
      # TODO: chain expressions keep it vor later
      # split expression into subexpression parts
      # @sub_expressions = expressions.split(/(AND|OR)/).each_slice(2).to_a
      
      @metric_names = services.monitoring.get_metric_names
    end
    
    # used by the wizard to get once all dimensions for given metric name
    def get_dimensions_for_metric
      name = params.require(:name)
      # get all dimensions 120 minutes ago
      t = Time.now.utc - (60*120)
      metrics = services.monitoring.get_metric({
        name: name, 
        start_time: t.iso8601
      })
      # default init with empty array
      dimensions = Hash.new{ |h, k| h[k] = [] }
      metrics.map{ |metric| metric.dimensions.select{ |key, value| dimensions[key] << value }}
      dimensions[''] << ''
      render json: dimensions
    end

    # used by wizard to render a new dimension row
    def dimension_row
      @cnt = params.require(:cnt).to_i
      @keys = JSON.parse(params.require(:keys));
      @next = @cnt + 1
      render partial: "dimension_row"
    end

    private
    
    def parse_expression(expression)
      # remove all white spaces
      expression.gsub!(/\s/,'')
      # parse expression
      result = expression.scan(/(avg|min|max|sum|count|\w+\.?\w+|\{.*\}|<|<=|>|>=|\d*\.?\d+)/)

      begin
        @statistical_function = result[0][0] || 'ERROR'
        @metric               = result[1][0] || 'ERROR'
        @dimensions           = result[2][0] || 'ERROR'
        @period               = result[3][0] || 'ERROR'
        @threshold            = result[4][0] || 'ERROR'
        @threshold_value      = result[5][0] || 'ERROR'
        
        # trim dimensions
        if @dimensions != 'ERROR'
          @dimensions.slice!('}')
          @dimensions.slice!('{')
        end
  
        # rebuild expression to check if everything was going right
        @parsed_expression = @statistical_function+"("+@metric+"{"+@dimensions+"},"+@period+")"+@threshold+@threshold_value
      rescue
        @parsed_expression = "Cannot parse! Please check the syntax of the expression."
      end 
    end

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
      id = params[:id] || params["id"]
      @alarm_definition = services.monitoring.get_alarm_definition(id)
      raise ActiveRecord::RecordNotFound, "alarm definition with id #{params[:id]} not found" unless @alarm_definition
    end

  end
end
