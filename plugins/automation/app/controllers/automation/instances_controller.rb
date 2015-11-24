module Automation

  class InstancesController < Automation::ApplicationController
    before_filter :init_automation

    def index
      @instances = services.compute.servers || []
      @instanceAgents = @automation.instanceAgents(current_user.token, @instances)
    end

    def show
      @instance_name = params[:name]
      @facts = @automation.list_agent_facts(current_user.token, params[:id])
      @jobs = @automation.list_jobs(current_user.token, params[:id])
    rescue ::RestClient::ResourceNotFound => exception
      Rails.logger.error "Automation-plugin: list_agent_facts: #{exception.message}"
      render "error_resource_not_found"
    end

    def show_log
      @job_id = params[:id]
      @log = @automation.find_job_log(current_user.token, @job_id)
      render :layout => false
    end

    def show_section
      @instances = services.compute.servers || []
      @instanceAgents = @automation.instanceAgents(current_user.token, @instances)
    end

    def install_agent
      @agent_id = params[:id]
      @agent_name = params[:name]
      @ip = params[:ip]

      # get url
      response = RestClient::Request.new(method: :post,
                                         url: "https://localhost:8443/api/v1/token",
                                         headers: {'X-Auth-Token': current_user.token},
                                         timeout: 5,
                                         payload: {"CN": @agent_id, "names": [{"OU": @active_project.id, "O": @active_project.domain_id}] }.to_json).execute

      # convert to hash
      response_hash = JSON.parse(response)
      @url = response_hash['url']
    end

    def init_automation
      @automation = ArcAutomation.new()
    end

  end

end