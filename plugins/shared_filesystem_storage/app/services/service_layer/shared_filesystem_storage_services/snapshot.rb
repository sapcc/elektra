# frozen_string_literal: true

module ServiceLayer
  module SharedFilesystemStorageServices
    # This module implements Openstack Designate Pool API
    module Snapshot
      def snapshot_map
        @snapshot_map ||= class_map_proc(SharedFilesystemStorage::Snapshot)
      end

      def snapshots(filter = {})
        elektron_shares.get("snapshots", filter).map_to(
          "body.snapshots",
          &snapshot_map
        )
      end

      def snapshots_detail(filter = {})
        elektron_shares.get("snapshots/detail", filter).map_to(
          "body.snapshots",
          &snapshot_map
        )
      end

      def find_snapshot!(id)
        elektron_shares.get("snapshots/#{id}").map_to(
          "body.snapshot",
          &share_map
        )
      end

      def find_snapshot(id)
        find_snapshot!(id)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      def new_snapshot(params = {})
        snapshot_map.call(params)
      end

      ################# INTERFACE METHODS ######################
      def create_snapshot(params)
        elektron_shares.post("snapshots") { { snapshot: params } }.body[
          "snapshot"
        ]
      end

      def update_snapshot(id, params)
        elektron_shares.put("snapshots/#{id}") { { snapshot: params } }.body[
          "snapshot"
        ]
      end

      def delete_snapshot(id)
        elektron_shares.delete("snapshots/#{id}")
      end
    end
  end
end
