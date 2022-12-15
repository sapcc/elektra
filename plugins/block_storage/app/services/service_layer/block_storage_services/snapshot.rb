# frozen_string_literal: true

module ServiceLayer
  module BlockStorageServices
    module Snapshot
      def snapshot_map
        @snapshot_map ||= class_map_proc(BlockStorage::Snapshot)
      end

      def snapshots(filter = {})
        elektron_volumes.get("snapshots", filter).map_to(
          "body.snapshots",
          &snapshot_map
        )
      end

      def snapshots_detail(filter = {})
        elektron_volumes.get("snapshots/detail", filter).map_to(
          "body.snapshots",
          &snapshot_map
        )
      end

      def find_snapshot!(id)
        return nil if id.blank?
        elektron_volumes.get("snapshots/#{id}").map_to(
          "body.snapshot",
          &snapshot_map
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

      ################## MODEL INTERFACE METHODS ####################
      def create_snapshot(params = {})
        elektron_volumes.post("snapshots") { { snapshot: params } }.body[
          "snapshot"
        ]
      end

      def update_snapshot(id, params = {})
        elektron_volumes.put("snapshots/#{id}") { { snapshot: params } }.body[
          "snapshot"
        ]
      end

      def delete_snapshot(id)
        elektron_volumes.delete("snapshots/#{id}")
      end

      def reset_snapshot_status(id, status = {})
        status = status.with_indifferent_access
        elektron_volumes.post("snapshots/#{id}/action") do
          {
            "os-reset_status" => {
              status: status["status"],
              attach_status: status["attach_status"],
              migration_status: status["migration_status"],
            },
          }
        end
      end
    end
  end
end
