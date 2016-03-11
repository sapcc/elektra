module Automation

  class AutomationsController < Automation::ApplicationController

    def index
      @automations = services.automation.automations
    end

    def new
      @automation_types = automation_types
      @automation = ::Automation::Forms::Automation.new()
    end

    def create
      @automation_types = automation_types
      @automation = nil

      # check automation type
      form_params = automation_params
      type = form_params['type']
      if type.blank?
        raise ArgumentError.new("Automation type missing")
      end

      # create automation type
      if type == 'chef'
        @automation = ::Automation::Forms::ChefAutomation.new(form_params)
      elsif type == 'script'
        @automation = ::Automation::Forms::ScriptAutomation.new(form_params)
      else
        raise ArgumentError.new("Automation type not known")
      end

      # validate and check
      if @automation.save(services.automation.automation_service)
        redirect_to automations_path, :flash => {success: "automation with name #{@automation.name} was successfully added."}
      else
         render action: "new"
      end
    rescue Exception => e
      Rails.logger.error e
      flash.now[:error] = "Error creating automation"
      render action: "new"
    end

    def show
      
    end

    private

    def automation_types
      {script: 'Script', chef: 'Chef'}
    end

    def automation_params
      unless params['forms_automation'].blank?
        return params.fetch('forms_automation', {})
      end
      unless params['forms_chef_automation'].blank?
        return params.fetch('forms_chef_automation', {})
      end
      unless params['forms_script_automation'].blank?
        return params.fetch('forms_script_automation', {})
      end
    end

  end

end
