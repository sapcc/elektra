# frozen_string_literal: true

module EmailService
  module Forms
    class VerifiedEmail
      include Virtus.model
      extend ActiveModel::Naming
      include ActiveModel::Conversion
      include ActiveModel::Validations
      include ActiveModel::Validations::Callbacks
      include ::EmailService::Helpers

      attribute :identity, String
      # attribute :tags, Array[Hash]
      attribute :configuration_set_name, String

      strip_attributes

      # validation
      validates_presence_of :identity, message: "email address can't be empty"
      validates :identity, presence: true, email: true

      def to_model
        self
      end

      def persisted?
        false
      end

      def process(email_identity_instance)
        process!(email_identity_instance)
      end

      private

      def process!(email_identity_instance)
        email_identity = email_identity_instance.new
        begin
          identity_array = email_identity.form_to_attributes(attributes)
        rescue StandardError => e
          errors.add 'email_identity_attributes'.to_sym, e.inspect
        end
        identity_array || errors
      end

      def assign_errors(messages)
        messages.each do |key, value|
          value.each { |item| errors.add key.to_sym, item }
        end
      end
    end
  end
end
