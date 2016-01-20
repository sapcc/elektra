module ServiceLayer
  class AutomationService < DomainModelServiceLayer::Service

    ARC_API_URL = "https://localhost/"

    def initialize(auth_url,region,token, options={})
      super(auth_url,region,token, options={})

      # Initialize ruby-arc-client
      @client = RubyArcClient::Client.new(ARC_API_URL)
    end


    def agents(filter="", show_facts=[], page=0, per_page=0)
      @client.list_agents!(current_user.token, filter, show_facts, page, per_page)
    end

    def agent_facts(agent_id = "")
      Automation::Facts.new(@client.show_agent_facts!(token, agent_id))
    end

    def agent_jobs(agent_id = "", page=0, per_page=100)
      @client.list_jobs!(token, agent_id)
    end

  end
end