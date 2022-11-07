module EmailService
    class Forms::VerifiedDomain

      include Virtus.model
      extend ActiveModel::Naming
      include ActiveModel::Conversion
      include ActiveModel::Validations
      include ActiveModel::Validations::Callbacks
      include ::EmailService::Helpers

      # Request
      attribute :domain_identity, String
      attribute :identity_type, String # one of "EMAIL_ADDRESS", "DOMAIN", "MANAGED_DOMAIN" # should be hidden default "DOAMIN"
      attribute :dkim_signing_attributes, Hash # Types::DkimSigningAttributes
      attribute :domain_signing_selector, String # part of :dkim_signing_attributes
      attribute :domain_signing_private_key, String # part of :dkim_signing_attributes
      attribute :next_signing_key_length, String # part of :dkim_signing_attributes  ; # accepts RSA_1024_BIT, RSA_2048_BIT
      attribute :tags, Array[Hash] # Atleast one tag pairs required
      attribute :configuration_set_name, String # Optional

      # Response
      attribute :dkim_attributes, Hash
      attribute :verified_for_sending_status, Boolean
      # get_email_identity Response
      attribute :feedback_forwarding_status, Boolean # Response
      # attribute :verified_for_sending_status, Boolean
      # attribute :dkim_attributes, Hash
        # resp.dkim_attributes.signing_enabled #=> Boolean
        # resp.dkim_attributes.status #=> String, one of "PENDING", "SUCCESS", "FAILED", "TEMPORARY_FAILURE", "NOT_STARTED"
        # resp.dkim_attributes.tokens #=> Array
        # resp.dkim_attributes.tokens[0] #=> String
        # resp.dkim_attributes.signing_attributes_origin #=> String, one of "AWS_SES", "EXTERNAL"
        # resp.dkim_attributes.next_signing_key_length #=> String, one of "RSA_1024_BIT", "RSA_2048_BIT"
        # resp.dkim_attributes.current_signing_key_length #=> String, one of "RSA_1024_BIT", "RSA_2048_BIT"
        # resp.dkim_attributes.last_key_generation_timestamp #=> Time
      attribute :mail_from_attributes, Hash
        # resp.mail_from_attributes.mail_from_domain #=> String
        # resp.mail_from_attributes.mail_from_domain_status #=> String, one of "PENDING", "SUCCESS", "FAILED", "TEMPORARY_FAILURE"
        # resp.mail_from_attributes.behavior_on_mx_failure #=> String, one of "USE_DEFAULT_VALUE", "REJECT_MESSAGE"
      attribute :policies, Hash
        # resp.policies #=> Hash
        # resp.policies["PolicyName"] #=> String
      # attribute :tags, Array[Hash] # Atleast one tag pairs required
        # resp.tags #=> Array
        # resp.tags[0].key #=> String
        # resp.tags[0].value #=> String
      # attribute :configuration_set_name, String # Optional
      attribute :verification_status, Boolean


      strip_attributes

      # validation
      validates_presence_of :domain_identity, message: "domain name can't be empty"
      validates :domain_identity, presence: true, domain: true

      def to_model
        self
      end

      def persisted?
        false
      end

      def process(domain_identity_instance)
        process!(domain_identity_instance)
      end

      private

      def process!(domain_identity_instance)

        domain_identity = domain_identity_instance.new
        begin
          domain_identity_array = domain_identity.form_to_attributes(attributes)
        rescue StandardError => e
          errors.add 'email_identity_attributes'.to_sym, e.inspect
        end
        domain_identity_array ? domain_identity_array : self.errors
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
