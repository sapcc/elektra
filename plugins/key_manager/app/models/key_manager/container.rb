require 'fog/key_manager/openstack/models/container'

module KeyManager

  class Container < ::Fog::KeyManager::OpenStack::Container

    module Type

      GENERIC = 'generic'
      CERTIFICATE = 'certificate'
      RSA = 'rsa'

      def self.to_hash
        res = {}
        res[GENERIC.to_sym] = 'Used for any type of container that a user may wish to create.'
        res[CERTIFICATE.to_sym] = 'Used for storing secrets: certificate, private_key (optional), private_key_passphrase (optional), intermediates (optional).'
        res[RSA.to_sym] = 'Used for storing RSA public keys, private keys, and private key pass phrases.'
        res
      end

    end

    module SecretsName

      CERTIFICATE = 'certificate'
      PRIVATE_KEY = 'private_key'
      PUBLIC_KEY = 'public_key'
      PRIVATE_KEY_PASSPHRASE = 'private_key_passphrase'
      INTERMEDIATES = 'intermediates'
      FREELY_SELECTED = 'freely selected'

      def self.realtion_to_type
        res = {}
        res[Type::GENERIC.to_sym] = [SecretsName::FREELY_SELECTED]
        res[Type::CERTIFICATE.to_sym] = [SecretsName::CERTIFICATE, SecretsName::PRIVATE_KEY, SecretsName::PRIVATE_KEY_PASSPHRASE, SecretsName::INTERMEDIATES]
        res[Type::RSA.to_sym] = [SecretsName::PRIVATE_KEY, SecretsName::PRIVATE_KEY_PASSPHRASE, SecretsName::PUBLIC_KEY]
        res
      end

    end

    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    prepend ::KeyManager::FogModelExtensions
    include ActiveModel::Validations::Callbacks

    strip_attributes

    identity :container_ref

    validates_presence_of :name, :type, :secret_refs

    def self.attributes
      ::Fog::KeyManager::OpenStack::Secret.attributes+super
    end

    def self.create_containers(_containers=[])
      total = nil
      unless _containers.blank?
        total = _containers.response.body.fetch('total', 0)
      end

      containers = []
      _containers.each do |_container|
        container = Container.new(_container.attributes)
        containers << container
      end
      {elements: containers, total_elements: total}
    end

    def display_name
      unless self.name.blank?
        self.name
      else
        'Empty name'
      end
    end

    def secrets
      self.secret_refs.each do |secret|
        secret['uuid'] = URI(secret['secret_ref']).path.split('/').last rescue nil
      end
    end

  end

end
