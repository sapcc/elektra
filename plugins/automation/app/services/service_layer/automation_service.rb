module ServiceLayer

  class ServiceNotAvailable < StandardError; end

  class AutomationService < Core::ServiceLayer::Service
    attr_reader :client

    def available?(action_name_sym=nil)
      !arc_service_endpoint.blank? && !automation_service_endpoint.blank?
    end

    def install_node_available?
      %w{arc_updates_url arc_pki_url arc_broker_url}.all? { |key| AUTOMATION_CONF[key].present? }
    end

    def arc_service_endpoint
      current_user.service_url('arc')
    end

    def automation_service_endpoint
      current_user.service_url('automation')
    end

    #
    # Nodes (Agents)
    #

    def nodes(filter="", show_facts=[], page=0, per_page=0)
      init_client
      ::Automation::Node.create_nodes(@client.list_agents!(current_user.token, filter, show_facts, page, per_page))
    end

    def node(node_id="", show_facts=[])
      init_client
      ::Automation::Node.new(@client.find_agent!(current_user.token, node_id, show_facts))
    end

    def node_facts(node_id = "")
      init_client
      ::Automation::Facts.new(@client.show_agent_facts!(token, node_id))
    end

    def node_add_tags(node_id = "", tags = {})
      init_client
      response = @client.add_agent_tags!(token, node_id, tags)
      !response.nil?
    end

    def node_delete_tag(node_id = "", key = "")
      init_client
      response = @client.delete_agent_tag!(token, node_id, key)
      !response.nil?
    end

    def node_delete(node_id = "")
      init_client
      response = @client.delete_agent!(token, node_id)
      !response.nil?
    end

    #
    # Jobs
    #

    def jobs(node_id = "", page=0, per_page=0)
      init_client
      Automation::Job.create_jobs( @client.list_jobs!(token, node_id, page, per_page) )
    end

    def job(job_id)
      init_client
      Automation::Job.new( @client.find_job!(token, job_id) )
    end

    def job_log(job_id)
      init_client
      @client.find_job_log!(token, job_id)
    end

    #
    # Automations
    #

    def automation_service
      Automation::Automation.site = ::File.join(ENV.fetch("LYRA_ENDPOINT") { automation_service_endpoint }, 'api/v1')
      Automation::Automation.token = self.token
      Automation::Automation
    end

    def automation_run_service
      Automation::Run.site = ::File.join(ENV.fetch("LYRA_ENDPOINT") { automation_service_endpoint }, 'api/v1')
      Automation::Run.token = self.token
      Automation::Run
    end

    def automations(page=0, per_page=0)
      automation_service.find(:all, :params => { page: page, per_page: per_page })
    end

    def automation(automation_id)
        automation_service.find(automation_id)
    end

    def automation_runs(page=0, per_page=0)
      automation_run_service.find(:all, :params => { page: page, per_page: per_page })
    end

    def automation_run(run_id)
      automation_run_service.find(run_id)
    end

    private

    def init_client
      if @client.nil? && !available?
        raise ServiceNotAvailable
      else
        @client = RubyArcClient::Client.new(arc_service_endpoint)
      end
    end

  end
end
