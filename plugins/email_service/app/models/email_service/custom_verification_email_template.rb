# frozen_string_literal: true

module EmailService
  class CustomVerificationEmailTemplate
    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ::EmailService::Helpers

    attribute :id, String
    attribute :template_name, String
    attribute :from_email_address, String
    attribute :template_subject, String
    attribute :template_content, String # The total size of the email must be less than 10 MB
    attribute :success_redirection_url, String
    attribute :failure_redirection_url, String

    strip_attributes

    # validation
    validates_presence_of :template_name,
                          message: "template name can't be empty"
    validates_presence_of :from_email_address,
                          message: "from email address can't be empty"
    validates_presence_of :template_subject,
                          message: "template subject can't be empty"
    validates_presence_of :template_content,
                          message: "template content can't be empty"
    validates_presence_of :success_redirection_url,
                          message: "success_redirection_url can't be empty"
    validates_presence_of :failure_redirection_url,
                          message: "failure_redirection_url can't be empty"

    validates :from_email_address, presence: true, email: true
    validates :success_redirection_url, presence: true, url: true
    validates :failure_redirection_url, presence: true, url: true

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
