# frozen_string_literal: true

module ServiceLayer
  module SharedFilesystemStorageServices
    # This module implements Openstack Manila Share API
    module ErrorMessage
      def error_message_map
        @error_message_map ||= class_map_proc(SharedFilesystemStorage::ErrorMessage)
      end

      def error_messages(filter = {})
        elektron_shares.get('messages', filter).map_to(
          'body.messages', &error_message_map
        )
      end
    end
  end
end
