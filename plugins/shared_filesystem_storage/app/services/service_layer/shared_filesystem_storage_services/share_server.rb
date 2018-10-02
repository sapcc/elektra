# frozen_string_literal: true

module ServiceLayer
  module SharedFilesystemStorageServices
    # This module implements Openstack Designate Pool API
    module ShareServer
      def share_server_map
        @share_server_map ||= class_map_proc(
          SharedFilesystemStorage::ShareServer
        )
      end

      def share_servers(filter = {})
        elektron_shares.get('share-servers', filter)
                       .map_to('body.share_servers', &share_server_map)
      end

      def find_share_server!(id)
        elektron_shares.get("share-servers/#{id}")
                       .map_to('body.share_server', &share_server_map)
      end

      def find_share_server(id)
        find_share_server!(id)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end
    end
  end
end
