module Automation

  class Forms::Automation
    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attr_accessor :token, :endpoint

    attribute :type, String
    attribute :name, String
    attribute :repository, String
    attribute :repository_revision, String
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
    validates :name, presence: true
    validates :repository, presence: true
    validates :type, presence: true


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

    private

    def persist!(automation_service)
      # Rest call for creating a autoamtion
      base_automation = automation_service.new()
      base_automation.form_to_attributes(self.attributes)
      success = base_automation.save
      unless success
        messages = !base_automation.errors.blank? || base_automation.errors.messages.blank? ? base_automation.errors.messages : {}
        base_automation.errors.messages.each do |key,value|
          value.each do |item|
            self.errors.add key.to_sym, item
          end
        end
      end
      success
    end

  end

end
