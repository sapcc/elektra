module ServiceLayer

  class ServiceNotAvailable < StandardError; end

  class AutomationService < Core::ServiceLayer::Service
    attr_reader :client

    def available?(action_name_sym=nil)
      !arc_service_endpoint.blank? && !automation_service_endpoint.blank?
    end

    def install_agent_available?
      !arc_update_site.blank? && !arc_pki.blank?
    end

    def arc_update_site
      AUTOMATION_CONF['arc_update_site_url']
    end

    def arc_pki
      AUTOMATION_CONF['arc_pki_url']
    end

    def arc_service_endpoint
      current_user.service_url('arc')
    end

    def automation_service_endpoint
      current_user.service_url('automation')
    end

    #
    # Agents
    #

    def agents(filter="", show_facts=[], page=0, per_page=0)
      init_client
      Automation::Agent.create_agents(@client.list_agents!(current_user.token, filter, show_facts, page, per_page))
    end

    def agent(agent_id="", show_facts=[])
      init_client
      Automation::Agent.new(@client.find_agent!(current_user.token, agent_id, show_facts))
    end

    def agent_facts(agent_id = "")
      init_client
      Automation::Facts.new(@client.show_agent_facts!(token, agent_id))
    end

    #
    # Jobs
    #

    def jobs(agent_id = "", page=0, per_page=0)
      init_client
      @client.list_jobs!(token, agent_id, page, per_page)
    end

    def job(job_id)
      init_client
      @client.find_job!(token, job_id)
    end

    def job_log(job_id)
      init_client
      @client.find_job_log!(token, job_id)
    end

    #
    # Automations
    #

    def automation_service
      Automation::Automation.site = File.join(automation_service_endpoint, 'api/v1') # 'http://localhost:3001/api/v1' # 'https://localhost/api/v1'
      Automation::Automation.token = self.token
      Automation::Automation
    end

    def automation_run_service
      Automation::Run.site = File.join(automation_service_endpoint, 'api/v1') # 'http://localhost:3001/api/v1' # 'https://localhost/api/v1'
      Automation::Run.token = self.token
      Automation::Run
    end

    def automations
      automation_service.find(:all)
    end

    def automation(automation_id)
        automation_service.find(automation_id)
    end

    def automation_runs
      automation_run_service.find(:all)
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