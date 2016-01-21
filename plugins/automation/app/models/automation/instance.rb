require 'ruby-arc-client'
require 'ostruct'

module Automation

  class Instance

    attr_accessor :id, :name, :os, :ip, :online, :external

    module OnlineState
      ONLINE  = true
      OFFLINE = false
    end

    module State
      MISSING = "-"
    end

    # TODO: implement search
    # TODO: sort by name not possible
    # TODO: paginate over instances?
    def self.create_instances(instances=[], agents=[])
      agentsMap = {}

      # create new objects from the agents
      agents.data.each do |agent|
        instanceAgent = Instance.new
        instanceAgent.id = agent.agent_id
        instanceAgent.name = agent.agent_id
        instanceAgent.ip = agent.facts.ipaddress || State::MISSING
        instanceAgent.online = agent.facts.online
        instanceAgent.external = true
        agentsMap[agent.agent_id] = instanceAgent
      end

      # match instances to agents,
      # change the name to the one from compute,
      # set external to false
      instances.each do |instance|
        if agentsMap.has_key?(instance.id)
          instanceAgent = agentsMap[instance.id]
          instanceAgent.name = instance.name
          instanceAgent.external = false
        end
      end

      # TODO: sort by name
      # agentsMap = agentsMap.sort_by{|_,v| v.name.downcase}.to_h

      {instances: agentsMap, total_elements: agents.pagination.total_elements}
    end

    def self.create_external_instances(instances=[], agent_ids=[])
      instancesMap = {}

      # create new objets from the instances
      instances.each do |instance|
        ext_instance = Instance.new
        ext_instance.id = instance.id
        ext_instance.name = instance.name
        ext_instance.os = instance.image.name
        ext_instance.ip = instance.ip_addresses.join(', ')
        instancesMap[ext_instance.id] = ext_instance
      end

      # match agents to instances
      agent_ids.data.each do |agent|
        if instancesMap.has_key?(agent.agent_id)
          instancesMap.delete(agent.agent_id)
        end
      end

      instancesMap
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

end