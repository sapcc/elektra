# frozen_string_literal: true

module KeyManager
  # barbican container
  class Container < ::Core::ServiceLayer::Model
    module Type
      GENERIC = "generic"
      CERTIFICATE = "certificate"
      RSA = "rsa"

      def self.to_hash
        {
          GENERIC.to_sym =>
            "Used for any type of container that a
                             user may wish to create.",
          CERTIFICATE.to_sym =>
            "Used for storing secrets: certificate,
                                 private_key (optional), private_key_passphrase
                                 (optional), intermediates (optional).",
          RSA.to_sym =>
            "Used for storing RSA public keys, private keys, and
                         private key pass phrases.",
        }
      end
    end

    module SecretsName
      CERTIFICATE = "certificate"
      PRIVATE_KEY = "private_key"
      PUBLIC_KEY = "public_key"
      PRIVATE_KEY_PASSPHRASE = "private_key_passphrase"
      INTERMEDIATES = "intermediates"
      FREELY_SELECTED = "freely selected"

      def self.realtion_to_type
        {
          Type::GENERIC.to_sym => [FREELY_SELECTED],
          Type::CERTIFICATE.to_sym => [
            CERTIFICATE,
            PRIVATE_KEY,
            PRIVATE_KEY_PASSPHRASE,
            INTERMEDIATES,
          ],
          Type::RSA.to_sym => [PRIVATE_KEY, PRIVATE_KEY_PASSPHRASE, PUBLIC_KEY],
        }
      end
    end

    strip_attributes
    validates_presence_of :name, :type, :secret_refs

    def attributes_for_create
      {
        "name" => read("name"),
        "secret_refs" => read("secret_refs"),
        "type" => read("type"),
      }.delete_if { |_k, v| v.blank? }
    end

    def id
      super || URI(container_ref).path.split("/").last
    rescue StandardError
      nil
    end

    def display_name
      name.blank? ? "Empty name" : name
    end

    def secrets
      secret_refs.each do |secret|
        secret["uuid"] = begin
          URI(secret["secret_ref"]).path.split("/").last
        rescue => _e
          nil
        end
      end
    end

    alias uuid id
  end
end
