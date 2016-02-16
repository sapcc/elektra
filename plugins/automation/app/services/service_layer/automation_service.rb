module ServiceLayer

  class ServiceNotAvailable < StandardError; end

  class AutomationService < DomainModelServiceLayer::Service

    attr_reader :client

    def available?(action_name_sym=nil)
      !service_end_point.blank?
      true
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

    def service_end_point
      current_user.service_url('arc')
    end

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

    def agent_jobs(agent_id = "", page=0, per_page=100)
      init_client
      @client.list_jobs!(token, agent_id)
    end

    private

    def init_client
      if @client.nil? && !available?
        raise ServiceNotAvailable
      else
        @client = RubyArcClient::Client.new(service_end_point)
      end
    end

  end
end