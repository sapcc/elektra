# frozen_String_literal: true

module ServiceLayer
  module KeyManagerServices
    # container api implementation
    module Container
      def container_map
        @container_map ||= class_map_proc(::KeyManager::Container)
      end

      def new_container(attributes = {})
        container_map.call(attributes)
      end

      def containers(filter = {})
        response = elektron_key_manager.get("containers", filter)
        {
          items: response.map_to("body.containers", &container_map),
          total: response.body["total"],
        }
      end

      def find_container!(uuid)
        elektron_key_manager.get("containers/#{uuid}").map_to(
          "body",
          &container_map
        )
      end

      def find_container(uuid)
        find_container!(uuid)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      ################ MODEL INTERFACE ###################
      def create_container(attributes = {})
        container_ref =
          elektron_key_manager.post("containers") { attributes }.body
        attributes.merge(container_ref)
      end

      def delete_container(id)
        elektron_key_manager.delete("containers/#{id}")
      end
    end
  end
end
