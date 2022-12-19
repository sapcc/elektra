# frozen_string_literal: true

module ServiceLayer
  module KeyManagerServices
    module Secret
      def secret_map
        @secret_map ||= class_map_proc(::KeyManager::Secret)
      end

      def secrets(filter = {})
        response = elektron_key_manager.get("secrets", filter)
        {
          items: response.map_to("body.secrets", &secret_map),
          total: response.body["total"],
        }
      end

      def find_secret!(uuid)
        elektron_key_manager.get("secrets/#{uuid}").map_to("body", &secret_map)
      end

      def find_secret(uuid)
        find_secret!(uuid)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      def new_secret(attributes = {})
        secret_map.call(attributes)
      end

      def secret_metadata!(uuid)
        elektron_key_manager.get("secrets/#{uuid}/metadata").body
      end

      def secret_metadata(uuid)
        secret_metadata!(uuid)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      def secret_payload!(uuid)
        elektron_key_manager.get(
          "secrets/#{uuid}/payload",
          headers: {
            "Accept" => "*/*",
          },
        ).body
      end

      def secret_payload(uuid)
        secret_payload!(uuid)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      def secret_payload_by_url(payload_link)
        elektron_key_manager.get(
          payload_link,
          headers: {
            "Accept" => "*/*",
          },
        ).body
      end

      def secret_with_metadata_payload(uuid)
        secret = find_secret(uuid)
        return nil unless secret
        metadata = secret_metadata(uuid)
        payload = secret_payload(uuid)
        secret.metadata = metadata if metadata
        secret.payload = payload if payload
        secret
      end

      #################### MODEL INTERFACE #######################
      def create_secret(attributes = {})
        elektron_key_manager.post("secrets") { attributes }.body
      end

      def delete_secret(id)
        elektron_key_manager.delete("secrets/#{id}")
      end
    end
  end
end
