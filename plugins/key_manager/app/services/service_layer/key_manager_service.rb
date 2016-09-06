require 'fog/key_manager/openstack/models/secret'

module ServiceLayer

  class KeyManagerService < Core::ServiceLayer::Service
    include Core::ServiceLayer::FogDriver::ClientHelper

    attr_reader :service
    
    def available?(action_name_sym=nil)

      not current_user.service_url('key-manager',region: region).nil?

    end

    #
    # Secrets
    #

    def secrets(filter={})
      begin
        all_secrets = service.secrets.all(filter)
        ::KeyManager::Secret.create_secrets(all_secrets)
      rescue => e
        raise ::KeyManager::ApiError.new(e), e.message
      end
    end

    def secret(uuid)
      begin
      secret_attr = service.secrets.get(uuid).attributes
      ::KeyManager::Secret.new(secret_attr.merge({service: service}))
      rescue => e
        raise ::KeyManager::ApiError.new(e), e.message
      end
    end

    def new_secret(attr)
      ::KeyManager::Secret.new(attr.merge({service: service}))
    end

    def secret_with_metadata_payload(uuid)
      # get the secret information
      begin
        secret_attr = service.secrets.get(uuid).attributes
        secret_metadata = service.get_secret_metadata(uuid).data.fetch(:body, {})
      rescue => e
        raise ::KeyManager::ApiError.new(e), e.message
      end

      # get extra the payload
      begin
        secret_payload = service.get_secret_payload(uuid).data.fetch(:body, "")
      rescue
        secret_payload = "Not available"
      end

      # create secret
      ::KeyManager::Secret.new(secret_attr.merge({service: service, metadata: secret_metadata, payload: secret_payload}))
    end

    #
    # Containers
    #

    def new_container(attr)
      ::KeyManager::Container.new(attr.merge({service: service}))
    end

    def containers(filter={})
      begin
        all_containers = service.containers.all(filter)
        ::KeyManager::Container.create_containers(all_containers)
      rescue => e
        raise ::KeyManager::ApiError.new(e), e.message
      end
    end

    def container(uuid)
      begin
        container_attr = service.containers.get(uuid).attributes
        ::KeyManager::Container.new(container_attr.merge({service: service}))
      rescue => e
        raise ::KeyManager::ApiError.new(e), e.message
      end
    end

    #
    # Helpers
    #

    def service
      @service ||= ::Fog::KeyManager::OpenStack.new(auth_params)
    end

  end
end