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
      @error = nil
      @instance = nil
      @instance_id = params[:instance_id]
      @version = params[:instance_os]
      @os_types = Agent.os_types

      if @instance_id.blank?
        return @error = {key: "warning", message: "Instance id is empty"}
      end

      # get instance
      @instance = begin
        services.compute.find_server(@instance_id)
      rescue DomainModelServiceLayer::Errors::ApiError => e
        case e.type
          when 'NotFound'
            nil
          else
            raise e
        end
      end

      # check if we got an instance
      if @instance.nil?
        return @error = {key: "warning", message: "Instance with id '#{@instance_id}' not found"}
      end

      # if version is not given then we check the metadata or we ask for
      if @version.blank?
        # check image metadata
        if @instance.image.metadata.nil? || @instance.image.metadata['os_family'].blank?
          return
        else
          # TODO need to check os version data
          @version = @instance.image.metadata['os_family']
        end
      end

      # check if agent already exists
      agent_found = ((services.automation.agent(@instance_id) rescue ::RestClient::ResourceNotFound) == ::RestClient::ResourceNotFound) ? false : true
      if agent_found
        return @error = "Agent already exists on instance id '#{@instance.id}' (#{@instance.image.name})"
      end

      # get url
      response = RestClient::Request.new(method: :post,
                                         url: AUTOMATION_CONF['arc_pki_url'],
                                         headers: {'X-Auth-Token': current_user.token},
                                         timeout: 5,
                                         payload: {"CN": @instance_id, "names": [{"OU": @active_project.id, "O": @active_project.domain_id}] }.to_json).execute

      #convert to hash
      response_hash = JSON.parse(response)
      @url = response_hash['url']
      @ip = @instance.addresses.values.blank? ? "" : @instance.addresses.values.first.find{|i| i['addr']}['addr']

    rescue => exception
      logger.error "Automation-plugin: show_instructions: #{exception.message}"
      return @error = {key: "danger", message: "Internal Server Error. Something went wrong while processing your request"}
    end

  end

end