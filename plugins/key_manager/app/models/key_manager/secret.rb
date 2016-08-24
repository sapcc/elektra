require 'fog/key_manager/openstack/models/secret'

module KeyManager

  class Secret < ::Fog::KeyManager::OpenStack::Secret
    #include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    identity :secret_ref

    # validation
    validates_presence_of :name

    def self.create_secrets(_secrets=[])
      secrets = []
      _secrets.each do |_secret|
        secret = Secret.new(_secret.attributes)
        secrets << secret
      end
      secrets
    end

    def display_name
      unless self.name.blank?
        self.name
      else
        'Empty name'
      end
    end

    def inspect
      vars = instance_variables.map do |n|
        "#{n}=#{instance_variable_get(n).inspect}"
      end
      "#<%s:0x%x %s>" % [self.class,object_id,vars.join(', ')]
    end

    def types
      {
        symmetric: 'Used for storing byte arrays such as keys suitable for symmetric encryption.',
        public: 'Used for storing the public key of an asymmetric keypair.',
        private: 'Used for storing the private key of an asymmetric keypair.',
        passphrase: 'Used for storing plain text passphrases.',
        certificate: ' Used for storing cryptographic certificates such as X.509 certificates.'
      }
    end

  end

end