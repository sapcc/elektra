module Automation

  class AutomationsController < ::Automation::ApplicationController
    before_action :automation, only: [:show, :edit]

    PER_PAGE = 10
    AUTOMATION_TYPE_UNKNOWN = I18n.t('automation.errors.automation_type_unknown')
    AUTOMATION_TYPE_MANIPULATED = I18n.t('automation.errors.automation_type_manipulated')

    def index
      if request.xhr?
        if params[:model] == 'run'
          runs_with_jobs(params[:page])
        elsif params[:model] == 'automation'
          automations(params[:page])
        end
      else
        automations(params[:page])
        runs_with_jobs(params[:page])
      end
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
      type = form_params.fetch('type',"")

      # create automation type
      @automation = automation_form(type, form_params)
      if @automation.nil?
        # in case someone manipulate the type we set the default chef type back manually
        @automation = ::Automation::Forms::ChefAutomation.new(form_params.merge(type: 'chef'))
        flash.now[:error] = AUTOMATION_TYPE_UNKNOWN
        return render action: "new"
      end

      # validate and check
      if @automation.save(services.automation.automation_service)
        #flash[:success] = "Automation #{@automation.name} was successfully added."
        redirect_to plugin('automation').automations_path
      else
         render action: "new"
      end
    rescue Exception => e
      Rails.logger.error e
      flash.now[:error] = I18n.t("automation.errors.automation_creation_error")
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

      # get original data and compare type
      orig_automation = services.automation.automation(form_params['id'])
      type = form_params.fetch('type',"")
      if type != orig_automation.type
        @automation = automation_form(orig_automation.type, form_params.merge({type: orig_automation.type}))
        flash.now[:error] = AUTOMATION_TYPE_MANIPULATED
        return render action: "edit"
      end

      # create model
      @automation = automation_form(type, form_params)

      # validate and save
      if @automation.update(services.automation.automation_service)
        #flash[:success] = "Automation #{@automation.name} was successfully updated."
        redirect_to plugin('automation').automations_path
      else
        render action: "edit"
      end
    rescue Exception => e
      Rails.logger.error e.message
      flash[:error] = I18n.t('automation.errors.automation_update_error')
      render action: "edit"
    end

    def destroy
      automation = services.automation.automation(params[:id])
      automation.destroy
      automations(1)
      runs_with_jobs(1)
      flash.now[:success] = I18n.t("automation.messages.automation_removed_successfully", name: automation.name)
      render action: "index"
    rescue Exception => e
      Rails.logger.error e.message
      flash.now[:error] = I18n.t('automation.errors.automation_remove_error')
      automations(1)
      runs_with_jobs(1)
      render action: "index"
    end

    private

    def automation
      automation = services.automation.automation(params[:id])
      @automation = ::Automation::Forms::Automation.new( automation.attributes_to_form)
    end

    def automations(page)
      @automations = services.automation.automations(page, PER_PAGE)
    end

    def runs_with_jobs(page)
      runs = services.automation.automation_runs(page, PER_PAGE)
      runs.each do |run|
        unless run.attributes['jobs'].nil?
          run.attributes['jobs_states'] = {'queued' => 0, 'failed' => 0, 'complete' => 0, 'executing' => 0}
          run.attributes['jobs'].each do |job_id|
            begin
              job = services.automation.job(job_id)
              run.attributes['jobs_states'][job.status] += 1
            rescue ArcClient::ApiError => exception
              if exception.code == 404
                # do nothing
              else
                raise exception
              end
            end
          end
        end
      end
      @runs = runs
    end

    def automation_form(type, form_params)
      if type.downcase == ::Automation::Automation::Types::CHEF.downcase
       return ::Automation::Forms::ChefAutomation.new(form_params)
      elsif type.downcase == ::Automation::Automation::Types::SCRIPT.downcase
        return ::Automation::Forms::ScriptAutomation.new(form_params)
      else
        return nil
      end
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
      return {}
    end

  end

end
