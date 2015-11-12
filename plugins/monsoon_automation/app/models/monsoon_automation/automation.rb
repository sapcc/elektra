require 'ruby-arc-client'
require 'ostruct'
require 'securerandom'

module MonsoonAutomation

  class Automation

    ARC_API_URL = "https://localhost/"

    module InstallationState
      INSTALLED   = true
      UNINSTALLED = false
    end

    module OnlineState
      ONLINE  = true
      OFFLINE = false
    end

    module State
      MISSING = "-"
    end

    InstanceAgent = Struct.new(:id, :name, :os, :ip, :agent, :version, :online) do
      def agent_to_string
        case self.agent
          when InstallationState::INSTALLED then "Installed"
          when InstallationState::UNINSTALLED then "Uninstalled"
          else
            'No State'
        end
      end

      def online_to_string
        case self.online
          when OnlineState::ONLINE then "Online"
          when OnlineState::OFFLINE then "Offline"
          else
            '-'
        end
      end
    end

    def instanceAgents(instances=[], token)
      withAgentMap = {}
      withoutAgentMap = {}
      externalAgentMap = {}

      # create instaceAgents
      instancesMap = {}
      instances.each do |instance|
        instance = InstanceAgent.new
        instance.id = instance.id
        instance.name = instance.name
        instance.os = instance.image.name
        instance.ip = instance.ip_addresses.join(', ')
        # empty agent attributes
        instance.agent = false
        instance.version = State::MISSING
        instance.online = State::MISSING
        withoutAgentMap[instance.id] = instance
      end

      # map instances with agents
      agents = list_agents(token)
      agents.each do |agent|
        if withoutAgentMap.has_key?(agent.agent_id)
          instanceAgent = withoutAgentMap[agent.agent_id]
          instanceAgent.agent = true
          instanceAgent.version = agent.facts.arc_version
          instanceAgent.online = agent.facts.online
          withAgentMap[agent.agent_id] = instanceAgent
          instancesMap.delete(agent.agent_id)
        else
          instanceAgent = InstanceAgent.new
          instanceAgent.id = agent.id
          instanceAgent.name = agent.hostname
          instanceAgent.os = agent.facts.os
          instanceAgent.ip = agent.facts.ip
          instanceAgent.agent = true
          instanceAgent.version = agent.facts.arc_version
          instanceAgent.online = agent.facts.online
          externalAgentMap[agent.id] = instanceAgent
        end
      end


      {withAgent: withAgentMap, withoutAgent: withoutAgentMap,  external: externalAgentMap}
    end

    def list_agents(token)
      client = RubyArcClient::Client.new(ARC_API_URL)
      client.list_agents(token, "", ['arc_version', 'online', 'os', 'hostname', 'ip'])
    end

    def instanceAgentsMock()
      withAgentMap = {}
      withoutAgentMap = {}
      externalAgentMap = {}

      instanceAgent = InstanceAgent.new(SecureRandom.hex, 'rhel6', 'RHEL6-x86_64', '10.44.57.194', true, '20151111.1 (cf691b9)', true)
      withAgentMap[instanceAgent.id] = instanceAgent
      instanceAgent = InstanceAgent.new(SecureRandom.hex, 'sles12', 'SLES12-x86_64', '10.44.57.130', true, '20151111.1 (cf691b9)', true)
      withAgentMap[instanceAgent.id] = instanceAgent
      instanceAgent = InstanceAgent.new(SecureRandom.hex, 'win2008', 'WINDOWS-2008R2-x86_64', '10.44.57.124', true, '20151111.1 (cf691b9)', true)
      withAgentMap[instanceAgent.id] = instanceAgent
      instanceAgent = InstanceAgent.new(SecureRandom.hex, 'sles11sp3', 'SAP-SLES11-SP3-x86_64', '10.44.57.125', true, '20151111.1 (cf691b9)', true)
      withAgentMap[instanceAgent.id] = instanceAgent
      instanceAgent = InstanceAgent.new(SecureRandom.hex, 'newUbuntu1404', 'UBUNTU1404-x86_64', '10.44.57.197', true, '20151111.1 (cf691b9)', true)
      withAgentMap[instanceAgent.id] = instanceAgent
      instanceAgent = InstanceAgent.new(SecureRandom.hex, 'win2012', 'win2012', '10.44.57.164', true, '20151111.1 (cf691b9)', true)
      withAgentMap[instanceAgent.id] = instanceAgent

      instanceAgent = InstanceAgent.new(SecureRandom.hex, 'mo-1ae70c6b6', 'RHEL6-x86_64', '10.44.57.194', true, '20151111.1 (cf691b9)', true)
      externalAgentMap[instanceAgent.id] = instanceAgent

      instanceAgent = InstanceAgent.new(SecureRandom.hex, 'ubuntu1404', 'UBUNTU1404-x86_64', '10.44.57.130', false, State::MISSING, State::MISSING)
      withoutAgentMap[instanceAgent.id] = instanceAgent
      instanceAgent = InstanceAgent.new(SecureRandom.hex, 'newSles12', 'SLES12-x86_64', '10.44.57.130', false, State::MISSING, State::MISSING)
      withoutAgentMap[instanceAgent.id] = instanceAgent

      {withAgent: withAgentMap, withoutAgent: withoutAgentMap,  external: externalAgentMap}
    end

    private

    def installation_state_string(state)
      case state
        when InstallationState::INSTALLED then "Installed"
        when InstallationState::UNINSTALLED then "Uninstalled"
        else
          'No State'
      end
    end

  end

end
