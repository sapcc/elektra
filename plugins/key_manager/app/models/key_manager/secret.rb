require 'fog/key_manager/openstack/models/secret'

module KeyManager

  class Secret < ::Fog::KeyManager::OpenStack::Secret

    module Status
      ACTIVE = 'ACTIVE'
    end

    module Type

      SYMMETRIC = 'symmetric'
      PUBLIC = 'public'
      PRIVATE = 'private'
      PASSPHRASE = 'passphrase'
      CERTIFICATE = 'certificate'
      OPAQUE = 'opaque'

      def self.to_hash
        res = {}
        res[SYMMETRIC.to_sym] = 'Used for storing byte arrays such as keys suitable for symmetric encryption'
        res[PUBLIC.to_sym] = 'Used for storing the public key of an asymmetric keypair'
        res[PRIVATE.to_sym] = 'Used for storing the private key of an asymmetric keypair'
        res[PASSPHRASE.to_sym] = 'Used for storing plain text passphrases'
        res[CERTIFICATE.to_sym] = 'Used for storing cryptographic certificates such as X.509 certificates'
        res[OPAQUE.to_sym] = 'Used for backwards compatibility with previous versions of the API without typed secrets'
        res
      end

    end

    module PayloadContentType

      OCTET_STREAM = 'application/octet-stream'
      TEXTPLAIN = 'text/plain'
      TEXTPLAIN_CHARSET_UTF8 = 'text/plain;charset=utf-8'
      PKCS8 = 'application/pkcs8'
      PKIX_CERT = 'application/pkix-cert'

      def self.relation_to_type
        res = {}
        res[Type::SYMMETRIC.to_sym] = [PayloadContentType::OCTET_STREAM]
        res[Type::PUBLIC.to_sym] = [PayloadContentType::OCTET_STREAM, PayloadContentType::TEXTPLAIN]
        res[Type::PRIVATE.to_sym] = [PayloadContentType::OCTET_STREAM, PayloadContentType::TEXTPLAIN]
        res[Type::PASSPHRASE.to_sym] = [PayloadContentType::TEXTPLAIN, PayloadContentType::TEXTPLAIN_CHARSET_UTF8]
        res[Type::CERTIFICATE.to_sym] = [PayloadContentType::PKCS8, PayloadContentType::PKIX_CERT, PayloadContentType::TEXTPLAIN]
        res[Type::OPAQUE.to_sym] = [PayloadContentType::TEXTPLAIN]
        res
      end

    end

    module Encoding

      BASE64 = 'base64'

      def self.relation_to_payload_content_type
        res = {}
        res[PayloadContentType::OCTET_STREAM.to_sym] = BASE64
        res[PayloadContentType::TEXTPLAIN.to_sym] = nil
        res[PayloadContentType::TEXTPLAIN_CHARSET_UTF8.to_sym] = nil
        res[PayloadContentType::PKCS8.to_sym] = BASE64
        res[PayloadContentType::PKIX_CERT.to_sym] = BASE64
        res
      end

    end


    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    prepend ::KeyManager::FogModelExtensions

    identity :secret_ref

    # validation
    validates_presence_of :name, :secret_type, :payload, :payload_content_type

    # TODO validate with condition
    # :payload_content_encoding

    def self.attributes
      ::Fog::KeyManager::OpenStack::Secret.attributes+super
    end

    def self.create_secrets(_secrets=[])
      total = nil
      unless _secrets.blank?
        total = _secrets.response.body.fetch('total', 0)
      end

      secrets = []
      _secrets.each do |_secret|
        secret = Secret.new(_secret.attributes)
        secrets << secret
      end
      {elements: secrets, total_elements: total}
    end

    def payload_link
      File.join(self.secret_ref, 'payload')
    end

    def payload_binary?
      if self.secret_type == Type::PASSPHRASE
        return false
      end
      return true
    end

    def display_bit_length
      if !self.bit_length.blank? && self.bit_length != 0
        return self.bit_length
      end
      ''
    end

    def display_name
      unless self.name.blank?
        self.name
      else
        'Empty name'
      end
    end

  end

end