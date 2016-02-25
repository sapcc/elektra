require 'ostruct'

module Automation

  class AgentsController < Automation::ApplicationController
    before_action :agents_with_jobs, only: [:index, :index_update]

    def index
    end

    def index_update
      render partial: 'table_instances', locals: {instances: @agents, jobs: @jobs}, layout: false
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
    end

    def show_instructions
      @instance_id = params[:instance_id]
      @instance_os = params[:instance_os]
      @os_types = Agent.os_types

      result = InstallAgentService.new().process_request(@instance_id, @instance_os, services.compute, services.automation, @active_project, current_user.token)
      @instance = result[:instance]
      @log_info = result[:log_info]
      @script = result[:script]

    rescue InstallAgentParamError => exception
      return @error = {key: "warning", message: exception.message}
    rescue InstallAgentAlreadyExists => exception
      return @error = {key: "warning", message: exception.message}
    rescue InstallAgentInstanceOSNotFound => exception
      @instance = exception.instance
      if params[:from] == 'select_os'
        return @error = {key: "warning", message: exception.message}
      end
    rescue InstallAgentError => exception
      return @error = {key: "warning", message: exception.message}
    rescue => exception
      logger.error "Automation-plugin: show_instructions: #{exception.message}"
      return @error = {key: "danger", message: "Internal Server Error. Something went wrong while processing your request"}
    end


    private

    def agents_with_jobs
      page = params[:page]||1
      per_page = 5
      result = IndexAgentsService.new(services.automation).list_agents(page, per_page)

      @agents = Kaminari.paginate_array(result[:elements], total_count: result[:total_elements]).
        page(page).
        per(per_page)
      @jobs = result[:jobs]
    end

  end

end
