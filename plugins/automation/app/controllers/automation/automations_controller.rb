module Automation
  class AutomationsController < ::Automation::ApplicationController
    authorization_context "automation"
    authorization_required

    before_action :automation,
                  only: %i[
                    show
                    edit
                    edit_repository_credentials
                    update_repository_credentials
                    remove_repository_credentials
                  ]

    PER_PAGE = 10
    AUTOMATION_TYPE_UNKNOWN =
      I18n.t("automation.errors.automation_type_unknown")
    AUTOMATION_TYPE_MANIPULATED =
      I18n.t("automation.errors.automation_type_manipulated")

    def index
      @pag_params = { automation: { page: 0 }, run: { page: 0 } }
      if request.xhr?
        if params[:model] == "run"
          @pag_params[:run][:page] = params[:page]
          runs_with_jobs(params[:page])
        elsif params[:model] == "automation"
          @pag_params[:automation][:page] = params[:page]
          automations(params[:page])
        end
      else
        @pag_params[:automation][:page] = params
          .fetch("pag_params", {})
          .fetch("automation", {})
          .fetch("page", 0)
        @pag_params[:run][:page] = params
          .fetch("pag_params", {})
          .fetch("run", {})
          .fetch("page", 0)
        automations(@pag_params[:automation][:page])
        runs_with_jobs(@pag_params[:run][:page])
      end
    end

    def index_update_runs
      @pag_params = { automation: { page: 0 }, run: { page: 0 } }
      @pag_params[:run][:page] = params[:page]
      runs_with_jobs(params[:page])
      render partial: "table_runs"
    end

    def new
      @automation_types = ::Automation::Automation.types
      @automation = ::Automation::Forms::Automation.new
    end

    def create
      @automation_types = ::Automation::Automation.types
      @automation = nil

      # check automation type
      form_params = automation_params
      type = form_params.fetch("type", "")

      # create automation type
      @automation = automation_form(type, form_params)
      if @automation.nil?
        # in case someone manipulate the type we set the default chef type back manually
        @automation =
          ::Automation::Forms::ChefAutomation.new(
            form_params.merge(type: "chef"),
          )
        flash.now[:error] = AUTOMATION_TYPE_UNKNOWN
        return render action: "new"
      end

      # validate and check
      if @automation.save(services.automation.automation_service)
        flash[
          :success
        ] = "Automation #{@automation.name} was successfully added."
        redirect_to plugin("automation").automations_path
      else
        render action: "new"
      end
    rescue Exception => e
      # Rails.logger.error e
      flash.now[
        :error
      ] = "#{I18n.t("automation.errors.automation_creation_error")} #{e.message}"
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
      orig_automation = services.automation.automation(form_params["id"])
      type = form_params.fetch("type", "")
      if type != orig_automation.type
        @automation =
          automation_form(
            orig_automation.type,
            form_params.merge(type: orig_automation.type),
          )
        flash.now[:error] = AUTOMATION_TYPE_MANIPULATED
        return render action: "edit"
      end

      # create model
      @automation = automation_form(type, form_params)

      # validate and save
      if @automation.update(services.automation.automation_service)
        flash[
          :success
        ] = "Automation #{@automation.name} was successfully updated."
        redirect_to plugin("automation").automations_path
      else
        render action: "edit"
      end
    rescue Exception => e
      # Rails.logger.error e.message
      flash[:error] = I18n.t("automation.errors.automation_update_error")
      render action: "edit"
    end

    def destroy
      automation = services.automation.automation(params[:id])
      automation.destroy
      automations(1)
      runs_with_jobs(1)
      flash.now[:success] = I18n.t(
        "automation.messages.automation_removed_successfully",
        name: automation.name,
      )
      render template: "automation/automations/update_item", formats: :js
    rescue Exception => e
      # Rails.logger.error e.message
      flash.now[:error] = I18n.t("automation.errors.automation_remove_error")
      automations(1)
      runs_with_jobs(1)
      render template: "automation/automations/update_item", formats: :js
    end

    def update_item
      @automation =
        begin
          services.automation.automation(params[:id])
        rescue StandardError
          nil
        end
    end

    private

    def automation
      automation = services.automation.automation(params[:id])
      @automation =
        ::Automation::Forms::Automation.new(automation.attributes_to_form)
    end

    def automations(page)
      @automations = services.automation.automations(page, PER_PAGE)
    end

    def runs_with_jobs(page)
      runs = services.automation.automation_runs(page, PER_PAGE)
      runs.each do |run|
        next if run.attributes["jobs"].nil?

        run.attributes["jobs_states"] = {
          "queued" => 0,
          "failed" => 0,
          "complete" => 0,
          "executing" => 0,
        }
        run.attributes["jobs"].each do |job_id|
          job = services.automation.job(job_id)
          run.attributes["jobs_states"][job.status] += 1
        rescue ArcClient::ApiError => e
          raise e unless e.code == 404
          # do nothing
        end
      end
      @runs = runs
    end

    def automation_form(type, form_params)
      if type.casecmp(::Automation::Automation::Types::CHEF).zero?
        ::Automation::Forms::ChefAutomation.new(form_params)
      elsif type.casecmp(::Automation::Automation::Types::SCRIPT).zero?
        ::Automation::Forms::ScriptAutomation.new(form_params)
      end
    end

    def automation_params
      p = params.to_unsafe_hash
      return p.fetch("forms_automation", {}) unless p["forms_automation"].blank?
      unless p["forms_chef_automation"].blank?
        return p.fetch("forms_chef_automation", {})
      end
      unless p["forms_script_automation"].blank?
        return p.fetch("forms_script_automation", {})
      end

      {}
    end
  end
end
