require "json"

module Automation
  class Forms::NodeTags
    include ::Automation::Helpers
    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attribute :agent_id, String
    attribute :tags, String #JSON

    strip_attributes

    def persisted?
      false
    end

    def save(service_automation)
      valid? ? update_tags(service_automation) : false
    end

    def update(service_automation)
      valid? ? update_tags(service_automation) : false
    end

    private

    def update_tags(service_automation)
      # get the original tags to compare
      node = service_automation.node(self.agent_id)
      old_tags = node.tags || {}

      # transform the given tags
      new_tags = string_to_hash(self.tags)

      # return if nothing todo
      return true if tags.blank? && old_tags.blank?

      # Get just the keys to add or update
      diff_tags = new_tags.to_a - old_tags.to_a
      add_tags = Hash[*diff_tags.flatten]

      # update + add keys
      unless add_tags.empty?
        begin
          service_automation.node_add_tags(self.agent_id, add_tags)
        rescue => e
          json_hash = ""
          json_hash = JSON[e.response] unless e.response.blank?

          if !json_hash.fetch("errors", nil).blank? &&
               !json_hash.fetch("errors", {}).fetch("tags", nil).blank?
            assign_tags_errors(json_hash["errors"]["tags"])
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
            service_automation.node_delete_tag(
              self.agent_id,
              ERB::Util.url_encode(key),
            )
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
        value.each { |item| error_messages << item }
      end

      self.errors.add :tags, error_messages.join(" ")
    end
  end
end
