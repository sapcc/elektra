module Automation

  class AutomationsController < ::Automation::ApplicationController
    before_action :automation, only: [:show, :edit]

    PER_PAGE = 10

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
        #flash[:success] = "Automation #{@automation.name} was successfully added."
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
        #flash[:success] = "Automation #{@automation.name} was successfully updated."
        redirect_to plugin('automation').automations_path
      else
        render action: "edit"
      end
    rescue Exception => e
      Rails.logger.error e
      flash.now[:error] = "Error updating automation."
      render action: "edit"
    end

    def destroy
      automation = services.automation.automation(params[:id])
      automation.destroy
      automations(1)
      runs_with_jobs(1)
      flash.now[:success] = "Automation #{automation.name} removed successfully."
      render action: "index"
    rescue Exception => e
      Rails.logger.error e
      flash.now[:error] = "Error removing automation."
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
      automations = services.automation.automations(page, PER_PAGE)
      @automations = Kaminari.paginate_array(automations, total_count: automations.http_response['Pagination-Elements'].to_i).
        page(automations.http_response['Pagination-Page'].to_i).
        per(automations.http_response['Pagination-Per-Page'].to_i)
    end

    def runs_with_jobs(page)
      runs = services.automation.automation_runs(page, PER_PAGE)
      runs.each do |run|
        unless run.jobs.nil?
          run.jobs_states = {queued: 0, failed: 0, complete: 0, executing:0}
          run.jobs.each do |job_id|
            begin
              job = services.automation.job(job_id)
              run.jobs_states[job.status.to_sym] += 1
            rescue RubyArcClient::ApiError => exception
              if exception.code == 404
                # do nothing
              else
                raise exception
              end
            end
          end
        end
      end
      @runs = Kaminari.paginate_array(runs, total_count: runs.http_response['Pagination-Elements'].to_i).
        page(runs.http_response['Pagination-Page'].to_i).
        per(runs.http_response['Pagination-Per-Page'].to_i)
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
