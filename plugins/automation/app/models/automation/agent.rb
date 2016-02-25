module Automation

  class Agent < RubyArcClient::Agent

    attr_accessor :id, :name

    def self.create_agents(_agents={})
      agentsMap = []
      _agents.data.each do |_agent|
        agent = Agent.new
        agent.id = _agent.agent_id
        agent.name = Agent.agent_name(_agent)
        agent.facts = Automation::Facts.new(_agent.facts)
        agentsMap << agent
      end
      {elements: agentsMap, total_elements: _agents.pagination.total_elements}
    end

    def self.os_types
      {"linux" => 'Linux', 'windows' => 'Windows'}
    end

    private

    def self.agent_name(_agent)
      if !_agent.tags.blank? && !_agent.tags['name'].blank?
        return _agent.tags['name']
      end
      _agent.facts.hostname
    end

  end

end
