# frozen_String_literal: true

module ServiceLayerNg
  module KeyManagerServices
    module Container
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
    end
  end
end
