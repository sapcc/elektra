# frozen_string_literal: true

module EmailService
  # Nebula Account
  class NebulaAccount < ::Core::ServiceLayer::Model
    def info
      {
        "production": true,
        "status": "GRANTED",
        "security_attributes": "security officer FirstName LastName (CID), environment DEV, valid until YYYY-MM-DD",
        "compliant": true,
        "id": null,

      }
    end

    module Status
      TERMINATED = "TERMINATED"
      DENIED = "DENIED"
      CUSTOMER_ACTION_COMPLETED = "CUSTOMER-ACTION-COMPLETED"
      PENDING_CUSTOMER_ACTION = "PENDING-CUSTOMER-ACTION"
      PENDING = "PENDING"
      NOT_ACTIVATED = "NOT_ACTIVATED"

      def self.to_hash
        {
          TERMINATED.to_sym => "Used to denote that the account has been terminated.",
          DENIED.to_sym => "Used to denote that the account has been denied.",
          CUSTOMER_ACTION_COMPLETED.to_sym => "Used to denote that the account has been completed customer action.",
          PENDING_CUSTOMER_ACTION.to_sym => "Used to denote that the account is pending customer action.",
          PENDING.to_sym => "Used to denote that the account is pending.",
          NOT_ACTIVATED.to_sym => "Used to denote that the account is not activated.",
        }
      end
    end

    module AccountEnvironment
      PROD = "PROD"
      QA = "QA"
      DEV = "DEV"
      DEMO = "DEMO"
      TRAIN = "TRAIN"
      SANDBOX = "SANDBOX"
      LAB = "LAB"
      def self.to_hash
        {
          PROD.to_sym => "Used for sending Production emails.",
          QA.to_sym => "Used for sending Quality Assurance emails.",
          DEV.to_sym => "Used for sending Development emails.",
          DEMO.to_sym => "Used for sending Demonstration emails.",
          TRAIN.to_sym => "Used for sending Training emails.",
          SANDBOX.to_sym => "Used for sending Sandbox emails.",
          LAB.to_sym => "Used for sending Laboratory emails.",
        }
      end
    end

    module MailType
      TRANSACTIONAL = "transactional"
      MARKETING = "marketing"
      def self.to_hash
        {
          TRANSACTIONAL.to_sym => "Used for sending transactional emails.",
          MARKETING.to_sym => "Used for sending marketing emails.",
        }
      end
    end

    module Provider
      AWS = "aws"
      OTHER = "other"
      def self.to_hash
        {
          AWS.to_sym => "Used for aws email provider.",
          OTHER.to_sym => "Used for other email provider.",
        }
      end
    end

    strip_attributes
    # validation
    validates_presence_of :account_env, message: "Account environment can't be empty"
    validates_presence_of :identity, message: "Identity can't be empty"
    validates_presence_of :mail_type, message: "Mail type can't be empty (aws)"
    validates_presence_of :provider, message: "provider can't be empty"
    validates_presence_of :security_officer, message: "A valid sap email address or SAP User ID of Security Officer is needed."
    validates :identity, presence: true, email_domain: true

    def attributes_for_create
      {
        "account_env" => read("account_env"),
        "identity" => read("identity"),
        "mail_type" => read("mail_type"),
        "provider" => read("provider"),
        "security_officer" => read("security_officer"),
      }.delete_if { |_k, v| v.blank? }
    end
  end
end
