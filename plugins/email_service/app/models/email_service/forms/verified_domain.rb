module EmailService
    class Forms::VerifiedDomain

      include Virtus.model
      extend ActiveModel::Naming
      include ActiveModel::Conversion
      include ActiveModel::Validations
      include ActiveModel::Validations::Callbacks
      include ::EmailService::Helpers

      attribute :domain, String
      attribute :identity_type, String
      attribute :sending_enabled, Boolean
      attribute :verification_status, Boolean
      attribute :dkim_enabled, Boolean
      attribute :tags, Array[Hash]
      attribute :domain_signing_selector, String
      attribute :domain_signing_private_key, String
      attribute :next_signing_key_length, String
      attribute :configuration_set_name, String
      attribute :feedback_forwarding_status, Boolean
      attribute :verified_for_sending_status, Boolean
      attribute :tags, Array[Hash]
      attribute :domain_signing_selector, String
      attribute :domain_signing_private_key, String
      attribute :next_signing_key_length, String
      attribute :configuration_set_name, String
      attribute :dkim_attributes, Hash
      attribute :mail_from_attributes, String
      attribute :policies, Hash


      strip_attributes

      # validation
      validates_presence_of :domain, message: "domain can't be empty"
      validates :domain, presence: true, email: true

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
        identity_array ? identity_array : self.errors

      end


      private

      def assign_errors(messages)
        messages.each do |key, value|
          value.each do |item|
            errors.add key.to_sym, item
          end
        end
      end

    end
  end
