# frozen_string_literal: true

module EmailService
  class Template < ::Core::ServiceLayer::Model
    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ::EmailService::Helpers

    attribute :name, String
    attribute :subject, String
    attribute :html_part, String
    attribute :text_part, String

    strip_attributes

    # validation
    validates_presence_of :name, message: "Name can't be empty"
    validates_presence_of :subject, message: "Subject can't be empty"
    validates_presence_of :html_part, message: "HTML part can't be empty"
    validates_presence_of :text_part, message: "Text part can't be empty"

    def to_model
      self
    end

    def persisted?
      false
    end

    private

    def assign_errors(messages)
      messages.each do |key, value|
        value.each { |item| errors.add key.to_sym, item }
      end
    end
  end
end
