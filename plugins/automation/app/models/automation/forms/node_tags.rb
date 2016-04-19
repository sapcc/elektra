require 'JSON'

module Automation

  class Forms::NodeTags
    include ::Automation::Helpers
    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attribute :agent_id, String
    attribute :tags, String #JSON

    def persisted?
      false
    end

    def save()
      if valid?
        update_tags(service_automation)
      else
        false
      end
    end

    def update(service_automation)
      if valid?
        update_tags(service_automation)
      else
        false
      end
    end

    private

    def update_tags(service_automation)
      # get the original tags to compare
      node = service_automation.node(self.agent_id)
      old_tags = node.tags
      # transform the given tags
      new_tags = JSON.parse(self.string_to_json(self.tags))

      # Get just the keys to add or update
      diff_tags = new_tags.to_a - old_tags.to_a
      add_tags = Hash[*diff_tags.flatten]

      # update + add keys
      unless add_tags.empty?
        begin
          service_automation.node_add_tags(self.agent_id, add_tags)
        rescue => e
          json_hash = ""
          unless e.response.blank?
            json_hash = JSON[e.response]
          end

          if !json_hash.fetch('errors', nil).blank? && !json_hash.fetch('errors',{}).fetch('tags',nil).blank?
            assign_tags_errors(json_hash['errors']['tags'])
          end

          return false
        end
      end

      # get the keys are being removed from the original tags
      diff_tags = old_tags.keys - new_tags.keys
      if diff_tags.count > 0
        # remove keys
        diff_tags.each do |key|
          begin
            service_automation.node_delete_tag(self.agent_id, ERB::Util.url_encode(key))
          rescue => e
            self.errors.add :tags, e.message

            return false
          end
        end
      end

      return true
    end

    def assign_tags_errors(messages)
      error_messages = []
      messages.each do |key, value|
        value.each do |item|
          error_messages << item
        end
      end

      self.errors.add :tags, error_messages.join(' ')
    end

  end

end