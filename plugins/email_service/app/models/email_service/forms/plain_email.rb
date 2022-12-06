module EmailService
  class Forms::PlainEmail

    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ::EmailService::Helpers

    attribute :source_type, String
    attribute :source, String
    attribute :source_email, String
    attribute :source_domain, String
    attribute :source_domain_name_part, String

    attribute :to_addr, String
    attribute :cc_addr, String
    attribute :bcc_addr, String
    attribute :return_path, String
    attribute :reply_to_addr, String

    attribute :subject, String
    attribute :html_body, String
    attribute :text_body, String
    attribute :configuration_set_name, String

    strip_attributes

    # validation
    validates_presence_of :source, message: "Sender can't be empty"
    validates_presence_of :to_addr, message: "To address can't be empty"
    validates_presence_of :subject, message: "Subject can't be empty"
    validates :to_addr, presence: true, email: true
    validates :cc_addr, allow_nil: true, email: true
    validates :bcc_addr, allow_nil: true, email: true

    def to_model
      self
    end

    def persisted?
      false
    end

    def process(plain_email_instance)
      process!(plain_email_instance)
    end

    private

    def process!(plain_email_instance)
      plain_email = plain_email_instance.new
      begin
        plain_email.form_to_attributes(attributes)
      rescue StandardError => e
        errors.add 'plain_email_attributes'.to_sym, e.inspect
      end
      if !plain_email.errors.blank?
        messages = plain_email.errors.blank? ? {} : plain_email.errors
        assign_errors(messages)
      end
      
      plain_email
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
