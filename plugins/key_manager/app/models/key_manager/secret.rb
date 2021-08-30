# frozen_string_literal: true

module KeyManager
  # represents the seret
  class Secret < Core::ServiceLayer::Model
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
        {
          SYMMETRIC.to_sym => 'Used for storing byte arrays such as keys
                               suitable for symmetric encryption',
          PUBLIC.to_sym => 'Used for storing the public key of an asymmetric
                            keypair',
          PRIVATE.to_sym => 'Used for storing the private key of an asymmetric
                             keypair',
          PASSPHRASE.to_sym => 'Used for storing plain text passphrases',
          CERTIFICATE.to_sym => 'Used for storing cryptographic certificates
                                 such as X.509 certificates',
          OPAQUE.to_sym => 'Used for backwards compatibility with previous
                            versions of the API without typed secrets'
        }
      end
    end

    module PayloadContentType
      OCTET_STREAM = 'application/octet-stream'
      TEXTPLAIN = 'text/plain'
      TEXTPLAIN_CHARSET_UTF8 = 'text/plain;charset=utf-8'
      PKCS8 = 'application/pkcs8'
      PKIX_CERT = 'application/pkix-cert'

      def self.relation_to_type
        {
          Type::SYMMETRIC.to_sym => [OCTET_STREAM],
          Type::PUBLIC.to_sym => [OCTET_STREAM, TEXTPLAIN],
          Type::PRIVATE.to_sym => [OCTET_STREAM, TEXTPLAIN],
          Type::PASSPHRASE.to_sym => [TEXTPLAIN, TEXTPLAIN_CHARSET_UTF8],
          Type::CERTIFICATE.to_sym => [PKCS8, PKIX_CERT, TEXTPLAIN],
          Type::OPAQUE.to_sym => [TEXTPLAIN, OCTET_STREAM]
        }
      end
    end

    module Encoding
      BASE64 = 'base64'

      def self.relation_to_payload_content_type
        {
          PayloadContentType::OCTET_STREAM.to_sym => BASE64,
          PayloadContentType::TEXTPLAIN.to_sym => nil,
          PayloadContentType::TEXTPLAIN_CHARSET_UTF8.to_sym => nil,
          PayloadContentType::PKCS8.to_sym => BASE64,
          PayloadContentType::PKIX_CERT.to_sym => BASE64
        }
      end
    end

    strip_attributes

    # validation
    validates_presence_of :name, :secret_type, :payload, :payload_content_type, :expiration

    def attributes_for_create
      attrs = {
        'name'                      => read('name'),
        'expiration'                => read('expiration'),
        'algorithm'                 => read('algorithm'),
        'mode'                      => read('mode'),
        'payload'                   => read('payload'),
        'payload_content_type'      => read('payload_content_type'),
        'payload_content_encoding'  => read('payload_content_encoding'),
        'secret_type'               => read('secret_type')
      }.delete_if { |_k, v| v.blank? }
      bit_length = read('bit_length')
      if bit_length && bit_length.to_i.positive?
        attrs['bit_length'] = bit_length.to_i
      end
      attrs
    end

    def id
      super || URI(secret_ref).path.split('/').last
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
