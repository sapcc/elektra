require 'ruby-arc-client'
require 'ostruct'
require 'securerandom'

module Automation

  class ArcAutomation

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
            State::MISSING
        end
      end

      def online_to_string
        case self.online
          when OnlineState::ONLINE then "Online"
          when OnlineState::OFFLINE then "Offline"
          else
            State::MISSING
        end
      end
    end

    class InstanceAgentFacts < RubyArcClient::Facts
      def attributes
        attr = self.marshal_dump
        attr.each do |k, v|
          if v != true && v != false && v != 'true' && v != 'false'
            if v.blank?
              attr[k] = State::MISSING
            end
          end
        end
        attr
      end
    end

    def instanceAgents(token, instances=[])
      withAgentMap = {}
      withoutAgentMap = {}
      externalAgentMap = {}

      # create instaceAgents from compute instances
      instancesMap = {}
      instances.each do |instance|
        instanceAgent = InstanceAgent.new
        instanceAgent.id = instance.id
        instanceAgent.name = instance.name
        instanceAgent.os = instance.image.name
        instanceAgent.ip = instance.ip_addresses.join(', ')
        # empty agent attributes
        instanceAgent.agent = false
        instanceAgent.version = State::MISSING
        instanceAgent.online = State::MISSING
        withoutAgentMap[instance.id] = instanceAgent
      end

      # map instances with agents
      agents = list_agents(token)
      agents.data.each do |agent|
        if withoutAgentMap.has_key?(agent.agent_id)
          # update instance with agent attributes
          instanceAgent = withoutAgentMap[agent.agent_id]
          instanceAgent.agent = true
          instanceAgent.version = agent.facts.arc_version
          instanceAgent.online = agent.facts.online
          withAgentMap[agent.agent_id] = instanceAgent
          withoutAgentMap.delete(agent.agent_id)
        else
          # create external instances with agents
          instanceAgent = InstanceAgent.new
          instanceAgent.id = agent.agent_id
          instanceAgent.name = agent.facts.hostname
          instanceAgent.os = agent.facts.os
          instanceAgent.ip = agent.facts.ip || State::MISSING
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
      client.list_agents!(token, "", ['arc_version', 'online', 'os', 'hostname', 'ip'])
    end

    def list_agent_facts(token, agent_id)
      client = RubyArcClient::Client.new(ARC_API_URL)
      InstanceAgentFacts.new( client.show_agent_facts!(token, agent_id) )
    end

    def list_jobs(token, agent_id)
      client = RubyArcClient::Client.new(ARC_API_URL)
      client.list_jobs!(token, agent_id)
    end

    def find_job_log(token, job_id)
      client = RubyArcClient::Client.new(ARC_API_URL)
      client.find_job_log!(token, job_id)
    end

  end

end