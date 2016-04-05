require 'ostruct'

module Automation

  class AgentsController < ::Automation::ApplicationController
    before_action :agents_with_jobs, only: [:index, :index_update]
    before_action :automations, only: [:index, :index_update]

    def index
    end

    def index_update
      render partial: 'table_agents', locals: {instances: @agents, jobs: @jobs}, layout: false
    end

    def show
      @instance_name = params[:name]
      @agent_id = params[:id]
      @facts = services.automation.agent_facts(@agent_id)
      @jobs = services.automation.jobs(@agent_id, 1, 100)
    rescue ::RestClient::ResourceNotFound => exception
      Rails.logger.error "Automation-plugin: list_agent_facts: #{exception.message}"
      render "error_resource_not_found"
    end

    def install
      @compute_instances = services.compute.servers
    end

    def show_instructions
      @instance_id = instance_info[:id]
      @instance_type = instance_info[:type]
      @instance_os = params[:instance_os]
      @os_types = Agent.os_types

      result = InstallAgentService.new().process_request(@instance_id, @instance_type, @instance_os, services.compute, services.automation, @active_project, current_user.token)
      @instance = result[:instance]
      @log_info = result[:log_info]
      @script = result[:script]
      @messages = result[:messages]

    rescue InstallAgentParamError => exception
      @messages = exception.options[:messages]
      return @errors = [{key: "warning", message: exception.message}]
    rescue InstallAgentInstanceOSNotFound => exception
      @messages = exception.options[:messages]
      @instance = exception.options[:instance]
      if params[:from] == 'select_os'
        return @errors = [{key: "warning", message: exception.message}]
      end
    rescue InstallAgentError => exception
      @messages = exception.options[:messages]
      return @errors = [{key: "danger", message: exception.message}]
    rescue => exception
      @messages = exception.options[:messages]
      logger.error "Automation-plugin: show_instructions: #{exception.message}"
      return @errors = [{key: "danger", message: "Internal Server Error. Something went wrong while processing your request"}]
    end

    def run_automation
      agent_id = params[:agent_id]
      automation_id = params[:automation_id]
      automation_name = params[:automation_name]
      run = services.automation.automation_run_service.new(automation_id: automation_id, selector: "@identity=#{agent_id}")
      if run.save
        flash.now[:success] = "Automation #{automation_name} was successfully executed. Click following #{view_context.link_to('link', plugin('automation').run_path(id: run.id), data: {modal: true}).html_safe} to see the details."
      else
        flash.now[:error] = "Error executing automation #{automation_name}. #{run.errors}"
      end
    rescue => exception
      logger.error "Automation-plugin: run_automation: #{exception.message}"
      flash.now[:error] = "Error executing automation '#{automation_name}'. Please try later"
    end

    private

    def instance_info
      unless params[:instance_type].nil?
        return {id: params[:instance_id], type: params[:instance_type]}
      else
        if params[:compute_instance_id] != 'external'
          return {id: params[:compute_instance_id], type: 'compute'}
        else
          return {id: params[:external_instance_id], type: 'external'}
        end
      end
    end

    def automations
      @automations = services.automation.automations
    end

    def agents_with_jobs
      page = params[:page]||1
      per_page = 5
      result = IndexAgentsService.new(services.automation).list_agents_with_jobs(page, per_page)

      @agents = Kaminari.paginate_array(result[:elements], total_count: result[:total_elements]).
        page(page).
        per(per_page)
      @jobs = result[:jobs]
    end

  end

end
