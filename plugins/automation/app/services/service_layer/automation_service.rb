module ServiceLayer
  class AutomationService < DomainModelServiceLayer::Service

    def initialize(auth_url,region,token, options={})
      super(auth_url,region,token, options={})

      # Initialize ruby-arc-client
      @client = RubyArcClient::Client.new(AUTOMATION_CONF['arc_api_url'])
    end


    def agents(filter="", show_facts=[], page=0, per_page=0)
      Automation::Agent.create_agents(@client.list_agents!(current_user.token, filter, show_facts, page, per_page))
    end

    def agent(agent_id="", show_facts=[])
      Automation::Agent.new(@client.find_agent!(current_user.token, agent_id, show_facts))
    end

    def agent_facts(agent_id = "")
      Automation::Facts.new(@client.show_agent_facts!(token, agent_id))
    end

    def agent_jobs(agent_id = "", page=0, per_page=100)
      @client.list_jobs!(token, agent_id)
    end

  end
end