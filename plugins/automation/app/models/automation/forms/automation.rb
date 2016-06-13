module Automation

  class Forms::Automation
    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attribute :id, String
    attribute :type, String
    attribute :name, String
    attribute :repository, String
    attribute :repository_revision, String, :default => 'master'
    attribute :tags, String #JSON
    attribute :timeout, Integer, :default => 3600

    # chef
    attribute :run_list, String #Array[String]
    attribute :chef_attributes, String #JSON
    attribute :log_level, String

    # script
    attribute :path, String
    attribute :arguments, String # Array[String]
    attribute :environment, String #JSON


    # validation
    validates_presence_of :name, :repository, :repository_revision, :type, :timeout

    def persisted?
      false
    end

    def save(automation_service)
      if valid?
        persist!(automation_service)
      else
        false
      end
    end

    def update(automation_service)
      if valid?
        update!(automation_service)
      else
        false
      end
    end

    private

    def persist!(automation_service)
      # Rest call for creating a autoamtion
      automation = automation_service.new()
      automation.form_to_attributes(self.attributes)
      success = automation.save
      unless success
        messages = !automation.errors.blank? && !automation.errors.messages.blank? ? automation.errors.messages : {}
        assign_errors(messages)
      end
      success
    end

    def update!(automation_service)
      automation = automation_service.find(self.id)
      automation.form_to_attributes(self.attributes)
      success = automation.save
      unless success
        messages = !automation.errors.blank? && !automation.errors.messages.blank? ? automation.errors.messages : {}
        assign_errors(messages)
      end
      success
    end

    def assign_errors(messages)
      messages.each do |key,value|
        value.each do |item|
          self.errors.add key.to_sym, item
        end
      end
    end

  end

end
