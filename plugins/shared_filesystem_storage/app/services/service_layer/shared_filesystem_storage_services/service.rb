# frozen_string_literal: true

module ServiceLayer
  module SharedFilesystemStorageServices
    # This module implements Openstack Manila Pool API
    module Service
      def service_map
        @service_map ||= class_map_proc(SharedFilesystemStorage::Service)
      end

      def services(filter = {})
        elektron_shares.get("services", filter).map_to(
          "body.services",
          &service_map
        )
      end
    end
  end
end
