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

      def self.to_hash
        res = {}
        res[SYMMETRIC.to_sym] = 'Used for storing byte arrays such as keys suitable for symmetric encryption'
        res[PUBLIC.to_sym] = 'Used for storing the public key of an asymmetric keypair'
        res[PRIVATE.to_sym] = 'Used for storing the private key of an asymmetric keypair'
        res[PASSPHRASE.to_sym] = 'Used for storing plain text passphrases'
        res[CERTIFICATE.to_sym] = ' Used for storing cryptographic certificates such as X.509 certificates'
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
        res[Type::PUBLIC.to_sym] = [PayloadContentType::OCTET_STREAM]
        res[Type::PRIVATE.to_sym] = [PayloadContentType::OCTET_STREAM]
        res[Type::PASSPHRASE.to_sym] = [PayloadContentType::TEXTPLAIN, PayloadContentType::TEXTPLAIN_CHARSET_UTF8]
        res[Type::CERTIFICATE.to_sym] = [PayloadContentType::PKCS8, PayloadContentType::PKIX_CERT]
        res
      end

    end

    module Encoding

      BASE64 = 'base64'

      def self.relation_to_type
        res = {}
        res[Type::SYMMETRIC.to_sym] = BASE64
        res[Type::PUBLIC.to_sym] = BASE64
        res[Type::PRIVATE.to_sym] = BASE64
        res[Type::PASSPHRASE.to_sym] = nil
        res[Type::CERTIFICATE.to_sym] = BASE64
        res
      end

    end

    module FogModelExtensions

      def save
        begin
          super
        rescue => e
          save_fog_errors(e)
          false
        end
      end

      def update
        begin
          super
        rescue => e
          save_fog_errors(e)
          false
        end
      end

      def create
        begin
          super
        rescue => e
          save_fog_errors(e)
          false
        end
      end

      def destroy
        begin
          super
        rescue => e
          save_fog_errors(e)
          false
        end
      end

      def save_fog_errors(exception)
        messages = get_api_error_messages(exception)
        if self.errors.messages[:global].nil?
          self.errors.messages[:global] = messages
        else
          self.errors.messages[:global] += messages
        end
      end

      def get_api_error_messages(error)
        if error.respond_to?(:response_data)
          return read_error_messages(error.response_data)
        elsif error.respond_to?(:response) and error.response.body
          response_data = JSON.parse(error.response.body) rescue error.response.body
          return read_error_messages(response_data)
        else
          [error.message]
        end
      end

      def read_error_messages(hash,messages=[])
        return [ hash.to_s ] unless hash.respond_to?(:each)
        hash.each do |k,v|
          messages << v if k=='message' or k=='type' or k=='description'
          if v.is_a?(Hash)
            read_error_messages(v,messages)
          elsif v.is_a?(Array)
            v.each do |value|
              read_error_messages(value,messages) if value.is_a?(Hash)
            end
          end
        end
        return messages
      end

    end




    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    prepend FogModelExtensions

    identity :secret_ref

    # validation
    validates_presence_of :name, :secret_type, :payload, :payload_content_type

    # TODO validate with condition
    # :payload_content_encoding

    def self.attributes
      ::Fog::KeyManager::OpenStack::Secret.attributes+super
    end

    def self.create_secrets(_secrets=[])
      secrets = []
      _secrets.each do |_secret|
        secret = Secret.new(_secret.attributes)
        secrets << secret
      end
      secrets
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