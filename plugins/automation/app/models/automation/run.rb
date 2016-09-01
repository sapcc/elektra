require 'active_resource'
require 'uri'

module Automation

  class Run < ::Automation::BaseActiveResource

    #
    # Added attribute classes to fix the activeresource load nested hashes with special keys like docker-compos
    #
    class AutomationAttributes < ActiveResource::Base
      def initialize(attributes = {}, persisted = false)
        @attributes     = attributes.with_indifferent_access
        @prefix_options = {}
        @persisted = persisted
      end
    end
    class Owner < ActiveResource::Base
      def initialize(attributes = {}, persisted = false)
        @attributes     = attributes.with_indifferent_access
        @prefix_options = {}
        @persisted = persisted
      end
    end

    self.collection_name = "runs"

    def duration
      time_diff = self.updated_at.to_time - self.created_at.to_time
      Time.at(time_diff.to_i.abs).utc.strftime "%H:%M:%S"
    end

    def state_to_string
      case self.state
        when State::Run::PREPARING then "Preparing"
        when State::Run::EXECUTING then "Executing"
        when State::Run::FAILED then "Failed"
        when State::Run::COMPLETED then "Completed"
        else
          State::MISSING
      end
    end

    def owner_name
      if self.owner.attributes["name"].nil?
        return self.owner.attributes["id"]
      else
        return self.owner.attributes["name"]
      end
    end

    def snapshot
      if !self.automation_attributes.blank? && self.automation_attributes.respond_to?(:attributes) && !self.automation_attributes.attributes.blank?
        return self.automation_attributes.attributes
      end
      {}
    end

    def revision_from_github?
      if !snapshot.empty? && !snapshot[:repository].blank? && !self.repository_revision.blank?
        host = URI(snapshot[:repository]).host
        if !host.blank? && host == "localhost"
          return true
        end
      end
      false
    end

    def revision_link
      if revision_from_github?
        return URI::join(snapshot[:repository].gsub!(/(.git\s*)*$/, '/'), 'commit/', self.repository_revision).to_s
      end
      self.repository_revision
    end

  end

end
