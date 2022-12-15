# frozen_string_literal: true

module ServiceLayer
  module SharedFilesystemStorageServices
    # This module implements Openstack Manila Pool API
    module Pool
      def pool_map
        @pool_map ||= class_map_proc(SharedFilesystemStorage::Pool)
      end

      def pools(filter = {})
        elektron_shares.get("scheduler-stats/pools/detail", filter).map_to(
          "body.pools",
          &pool_map
        )
      end

      def find_pool!(id)
        pools(pool: id).first
      end

      def find_pool(id)
        find_pool!(id)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end
    end
  end
end
