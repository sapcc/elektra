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

    def show_section
      servers = services.compute.servers
      agents = services.automation.agents("", ['online', 'hostname', 'os', 'ipaddress'], 1, 100)
      @instances = Instance.create_instances_without_agents(servers, agents)
    end

    def install_agent
    end

    def show_instructions
      instance_id = params[:instance_id]

      # get instance
      server = begin
        services.compute.find_server(instance_id)
      rescue DomainModelServiceLayer::Errors::ApiError => e
        case e.type
        when 'NotFound'
          nil
        else
          raise e
        end
      end

      # check if instance exists
      if server.nil?
        return @error = {key: "warning", message: "Instance with id '#{instance_id}' not found"}
      end

      # check image info
      if server.image.metadata.os_family.blank? || server.image.metadata.os_version.blank?
        @version = ""
      end


      # check if agent already exists
      agent_found = ((services.automation.agent(instance_id) rescue ::RestClient::ResourceNotFound) == ::RestClient::ResourceNotFound) ? false : true
      if agent_found
        return @error = "Agent already exists on instance id '#{server.id}' (#{server.image.name})"
      end

      # get url
      response = RestClient::Request.new(method: :post,
                                         url: AUTOMATION_CONF['arc_pki_url'],
                                         headers: {'X-Auth-Token': current_user.token},
                                         timeout: 5,
                                         payload: {"CN": instance_id, "names": [{"OU": @active_project.id, "O": @active_project.domain_id}] }.to_json).execute

      #convert to hash
      response_hash = JSON.parse(response)
      @url = response_hash['url']
    rescue => exception
      logger.error "Automation-plugin: show_instructions: #{exception.message}"
      return @error = {key: "danger", message: "Internal Server Error. Something went wrong while processing your request"}
    end

  end

end