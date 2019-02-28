module Automation
  class Forms::Automation
    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attribute :id, String
    attribute :type, String
    attribute :name, String
    attribute :repository, String
    attribute :repository_revision, String, default: 'master'
    attribute :tags, String # JSON
    attribute :timeout, Integer, default: 3600

    # chef
    attribute :run_list, String # Array[String]
    attribute :chef_attributes, String # JSON
    attribute :log_level, String
    attribute :chef_version, String
    attribute :debug, Boolean

    # script
    attribute :path, String
    attribute :arguments, String # Array[String]
    attribute :environment, String # JSON

    strip_attributes

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
      automation = automation_service.new
      begin
        automation.form_to_attributes(attributes)
      rescue JSON::ParserError => e
        # catch chef attributes json parse error
        errors.add 'chef_attributes'.to_sym, e.inspect
        return false
      end
      success = automation.save!
      if !success || !automation.errors.blank?
        messages = automation.errors.blank? ? {} : automation.errors
        assign_errors(messages)
      end
      success
    end

    def update!(automation_service)
      automation = automation_service.find(id)
      begin
        automation.form_to_attributes(attributes)
      rescue JSON::ParserError => e
        # catch chef attributes json parse error
        errors.add 'chef_attributes'.to_sym, e.inspect
        return false
      end
      success = automation.save!
      if !success || !automation.errors.blank?
        messages = automation.errors.blank? ? {} : automation.errors
        assign_errors(messages)
      end
      success
    end

    def assign_errors(messages)
      messages.each do |key, value|
        value.each do |item|
          errors.add key.to_sym, item
        end
      end
    end
  end
end
