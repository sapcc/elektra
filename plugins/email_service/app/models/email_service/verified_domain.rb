# frozen_string_literal: true

module EmailService
  class VerifiedDomain
    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ::EmailService::Helpers

    attribute :identity_name, String
    attribute :identity_type, String # one of "EMAIL_ADDRESS", "DOMAIN", "MANAGED_DOMAIN" # should be hidden default "DOAMIN"
    attribute :dkim_type, String
    attribute :dkim_signing_attributes, Hash # Types::DkimSigningAttributes
    attribute :domain_signing_selector, String # part of :dkim_signing_attributes
    attribute :domain_signing_private_key, String # part of :dkim_signing_attributes
    attribute :next_signing_key_length, String # part of :dkim_signing_attributes  ; # accepts RSA_1024_BIT, RSA_2048_BIT
    attribute :tags, Array[Hash] # Atleast one tag pairs required
    attribute :configuration_set_name, String # Optional
    attribute :sending_enabled, Boolean
    attribute :verification_status, String #=> String, one of "PENDING", "SUCCESS", "FAILED", "TEMPORARY_FAILURE", "NOT_STARTED"
    attribute :dkim_attributes, Hash
    attribute :verified_for_sending_status, Boolean
    attribute :feedback_forwarding_status, Boolean # Response
    attribute :mail_from_attributes, Hash
    attribute :policies, Hash
    attribute :verification_status, Boolean

    strip_attributes

    validates_presence_of :identity_name, message: "domain name can't be empty"
    validates :identity_name, presence: true, domain: true

    module KeyLength
      RSA_1024_BIT = 'RSA_1024_BIT'
      RSA_2048_BIT = 'RSA_2048_BIT'
    end

    def self.key_length
      {
        RSA_1024_BIT: ::EmailService::VerifiedDomain::KeyLength::RSA_1024_BIT,
        RSA_2048_BIT: ::EmailService::VerifiedDomain::KeyLength::RSA_2048_BIT
      }
    end

    module DKIMType
      EASYDKIM = 'easy_dkim'
      BYODKIM = 'byo_dkim'
    end

    def self.dkim_types
      {
        easy_dkim: ::EmailService::VerifiedDomain::DKIMType::EASYDKIM,
        byo_dkim: ::EmailService::VerifiedDomain::DKIMType::BYODKIM,
      }
    end
  end
end
