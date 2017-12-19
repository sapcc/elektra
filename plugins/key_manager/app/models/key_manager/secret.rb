# frozen_string_literal: true

module KeyManager
  # represents the seret
  class Secret < Core::ServiceLayerNg::Model
    module Status
      ACTIVE = 'ACTIVE'
    end

    # Secret types
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

    strip_attributes

    # validation
    validates_presence_of :name, :secret_type, :payload, :payload_content_type

    def id
      URI(secret_ref).path.split('/').last
    rescue
      nil
    end

    def payload_link
      File.join(secret_ref, 'payload')
    end

    def payload_binary?
      secret_type != Type::PASSPHRASE
    end

    def display_bit_length
      !bit_length.blank? && bit_length != 0 ? bit_length : ''
    end

    def display_name
      name.blank? ? 'Empty name' : name
    end

    alias uuid id
  end
end
