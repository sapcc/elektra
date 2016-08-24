require 'fog/key_manager/openstack/models/secret'

module ServiceLayer

  class KeyManagerService < Core::ServiceLayer::Service
    include Core::ServiceLayer::FogDriver::ClientHelper

    attr_reader :service
    
    def available?(action_name_sym=nil)
      true  
    end
    

    def secrets(filter={})
      ::KeyManager::Secret.create_secrets(service.secrets.all(filter))
    end

    def secret(uuid)
      ::KeyManager::Secret.new(service.secrets.get(uuid))
    end

    def new_secret(attr)
      ::KeyManager::Secret.new(attr.merge({service: service}))
    end

    def service
      @service ||= ::Fog::KeyManager::OpenStack.new(auth_params)
    end

  end
end