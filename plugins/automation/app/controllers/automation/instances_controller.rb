require 'ostruct'

module Automation

  class InstancesController < Automation::ApplicationController

    def index
      result = services.automation.agents("", ['online', 'hostname', 'os', 'ipaddress'], 1, 10)
      page = params[:page]||1
      per_page = 5

      @agents = Kaminari.paginate_array(result[:elements], total_count: result[:total_elements]).
        page(page).
        per(per_page)
    end

    def show
      @instance_name = params[:name]
      @facts = services.automation.agent_facts(params[:id])
      @jobs = services.automation.agent_jobs(params[:id], 1, 100)
    rescue ::RestClient::ResourceNotFound => exception
      Rails.logger.error "Automation-plugin: list_agent_facts: #{exception.message}"
      render "error_resource_not_found"
    end

    def show_log
      @job_id = params[:id]
      @log = @automation.find_job_log(current_user.token, @job_id)
      render :layout => false
    end

    def install_agent
    end

    def show_instructions
      @instance_id = params[:instance_id]
      @instance_os = params[:instance_os]
      @os_types = Agent.os_types

      result = InstallAgentService.new().process_request(@instance_id, @instance_os, services.compute, services.automation, @active_project, current_user.token)
      @instance = result[:instance]
      @url = result[:url]
      @ip = result[:ip]
      @instance_os = result[:instance_os]

    rescue InstallAgentParamError => exception
      return @error = {key: "warning", message: exception.message}
    rescue InstallAgentAlreadyExists => exception
      return @error = {key: "warning", message: exception.message}
    rescue InstallAgentInstanceOSNotFound => exception
      @instance = exception.instance
      if params[:from] == 'select_os'
        return @error = {key: "warning", message: exception.message}
      end
    rescue => exception
      logger.error "Automation-plugin: show_instructions: #{exception.message}"
      return @error = {key: "danger", message: "Internal Server Error. Something went wrong while processing your request"}
    end

  end

end
