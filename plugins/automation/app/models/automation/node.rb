module Automation

  class Node < ArcClient::Agent
    include ::Automation::Helpers

    module OsTypes
      LINUX = "linux"
      WINDOWS = "windows"
    end

    attr_accessor :id, :name

    def self.create_nodes(_agents={})
      nodesMap = []
      _agents.data.each do |_agent|
        node = ::Automation::Node.new(_agent)
        nodesMap << node
      end
      {elements: nodesMap, total_elements: _agents.pagination.total_elements}
    end

    def id
      self.agent_id
    end

    def automation_facts
      ::Automation::Facts.new(self.facts)
    end

    def self.os_types
      {OsTypes::LINUX => 'Linux', OsTypes::WINDOWS => 'Windows'}
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

    def attributes_to_form
      attr = self.marshal_dump.clone
      attr.keys.each do |key|
        if key == :tags
          unless attr[key].blank?
            attr[key] = json_to_string( attr[key] )
          end
        end
      end
      attr
    end

    private

  end

end
