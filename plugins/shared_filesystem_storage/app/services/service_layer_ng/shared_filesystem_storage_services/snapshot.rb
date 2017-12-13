# frozen_string_literal: true

module ServiceLayerNg
  module SharedFilesystemStorageServices
    # This module implements Openstack Designate Pool API
    module Snapshot
      def snapshot_map
        @snapshot_map ||= class_map_proc(SharedFilesystemStorage::SnapshotNg)
      end

      def snapshots(filter = {})
        elektron_shares.get('snapshots', filter)
                       .map_to('body.snapshots', &snapshot_map)
      end

      def snapshots_detail(filter = {})
        elektron_shares.get('snapshots/detail', filter)
                       .map_to('body.snapshots', &snapshot_map)
      end

      def find_snapshot!(id)
        elektron_shares.get("snapshots/#{id}", filter)
                       .map_to('body.snapshot', &share_map)
      end

      def find_snapshot(id)
        find!(id)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      def new_snapshot(params = {})
        snapshot_map.call(params)
      end

      ################# INTERFACE METHODS ######################
      def create_snapshot_ng(params)
        elektron_shares.post('snapshots') do
          { snapshot: params }
        end.body['snapshot']
      end

      def update_snapshot_ng(id, params)
        elektron_shares.put("snapshots/#{id}") do
          { snapshot: params }
        end.body['snapshot']
      end

      def delete_snapshot_ng(id)
        elektron_shares.delete("snapshots/#{id}")
      end
    end
  end
end
