# frozen_string_literal: true

module ServiceLayerNg
  module SharedFilesystemStorageServices
    # This module implements Openstack Designate Pool API
    module Share
      def share_types
        api.shared_file_systems.list_share_types.map_to(
          response_body: SharedFilesystemStorage::ShareTypeNg)
      end

      def list_all_major_versions
        api.shared_file_systems.list_all_major_versions
      end
    end
  end
end
