module Automation

  class InstancesController < Automation::ApplicationController

    def index
      # get all severs (max limit is 1000)
      servers = services.compute.servers
      agents = services.automation.agents("", ['online', 'hostname', 'os', 'ipaddress'], 1, 10)
      @instances = Instance.create_instances(servers, agents)
      @external_instances = Instance.create_external_instances(servers, agents)
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

    def show_section
      @instances = services.compute.servers || []
      @instanceAgents = ArcAutomation.new().instanceAgents(current_user.token, @instances)
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

  end

end