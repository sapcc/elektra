module Automation

  class AutomationsController < ::Automation::ApplicationController
    before_action :automation, only: [:show, :edit]

    def index
      @automations = services.automation.automations
      @runs = services.automation.automation_runs
    end

    def new
      @automation_types = ::Automation::Automation.types
      @automation = ::Automation::Forms::Automation.new()
    end

    def create
      @automation_types = ::Automation::Automation.types
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
        flash[:success] = "Automation #{@automation.name} was successfully added."
        redirect_to plugin('automation').automations_path
      else
         render action: "new"
      end
    rescue Exception => e
      Rails.logger.error e
      flash.now[:error] = "Error creating automation"
      render action: "new"
    end

    def show
      @automation_types = ::Automation::Automation.types
    end

    def edit
    end

    def update
      @automation_form = nil
      form_params = automation_params

      # check type and create model
      if form_params['type'] == ::Automation::Automation::Types::CHEF
        @automation = ::Automation::Forms::ChefAutomation.new(form_params)
      elsif form_params['type'] == ::Automation::Automation::Types::SCRIPT
        @automation = ::Automation::Forms::ScriptAutomation.new(form_params)
      else
        raise ArgumentError.new("Automation type not known")
      end

      # validate and save
      if @automation.update(services.automation.automation_service)
        flash[:success] = "Automation #{@automation.name} was successfully updated."
        redirect_to plugin('automation').automations_path
      else
        render action: "edit"
      end
    rescue Exception => e
      Rails.logger.error e
      flash.now[:error] = "Error updating automation."
      render action: "edit"
    end

    private

    def automation
      automation = services.automation.automation(params[:id])
      @automation = ::Automation::Forms::Automation.new( automation.attributes_to_form)
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
