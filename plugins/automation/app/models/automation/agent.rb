module Automation

  class Agent < RubyArcClient::Agent

    attr_accessor :id, :name

    def self.create_agents(_agents={})
      agentsMap = []
      _agents.data.each do |_agent|
        agent = Agent.new(_agent)
        agentsMap << agent
      end
      {elements: agentsMap, total_elements: _agents.pagination.total_elements}
    end

    def id
      self.agent_id
    end

    def automation_facts
      ::Automation::Facts.new(self.facts)
    end

    def self.os_types
      {"linux" => 'Linux', 'windows' => 'Windows'}
    end

    def name
      if !self.tags.blank? && !self.tags['name'].blank?
        return self.tags['name']
      end
      if !self.automation_facts.hostname.blank?
        return self.automation_facts.hostname
      end
      self.id
    end

    private

  end

end
