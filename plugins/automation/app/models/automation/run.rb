require 'lyra_client'
require 'uri'

module Automation

  class Run < LyraClient::Base
    include ::Automation::Helpers

    self.collection_name = "runs"

    def duration
      time_diff = self.updated_at.to_time - self.created_at.to_time
      Time.at(time_diff.to_i.abs).utc.strftime "%H:%M:%S"
    end

    def owner_name
      if self.attributes.fetch('owner', {})["name"].nil?
        return self.attributes.fetch('owner', {})["id"]
      else
        return self.attributes.fetch('owner', {})["name"]
      end
    end

    def snapshot
      unless self.automation_attributes.blank?
        return self.automation_attributes
      end
      {}
    end

    def revision_from_github?
      if !snapshot.empty? && !snapshot[:repository].blank? && !self.repository_revision.blank?
        host = URI(snapshot[:repository]).host
        if !host.blank? && host.include?("github")
          return true
        end
      end
      false
    end

    def revision_link
      if revision_from_github?
        return URI::join(snapshot[:repository].sub!(/(\.git\s*)/, '/'), 'commit/', self.repository_revision).to_s
      end
      self.repository_revision
    end

    def respond_to?(method_name, include_private = false)
      keys = @attributes.keys
      keys.include?(method_name.to_s) or keys.include?(method_name.to_sym) or super
    end

    def method_missing(method_name, *args, &block)
      keys = @attributes.keys
      if keys.include?(method_name.to_s)
        @attributes[method_name.to_s]
      elsif keys.include?(method_name.to_sym)
        @attributes[method_name.to_sym]
      else
        super
      end
    end

  end

end
