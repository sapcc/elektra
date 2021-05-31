# frozen_string_literal: true

module ServiceLayer
  module SharedFilesystemStorageServices
    module Replica

      # need to use api version 2.56 
      def elektron_share_replicas
        @elektron_share_replicas ||= elektron.service(
          'sharev2',
          headers: { 'X-OpenStack-Manila-API-Version' => "2.56" }
        )
      end

      def replica_map
        @replica_map ||= class_map_proc(SharedFilesystemStorage::Replica)
      end

      def replicas(filter = {})
        elektron_share_replicas.get('share-replicas', filter)
                       .map_to('body.share_replicas', &replica_map)           
      end

      def replicas_detail(filter = {})
        elektron_share_replicas.get('share-replicas/detail', filter)
                       .map_to('body.share_replicas', &replica_map)

      end

      def find_replica!(id)
        elektron_share_replicas.get("share-replicas/#{id}")
                       .map_to('body.share_replica', &share_map)
      end

      def find_replica(id)
        find_replica!(id)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      def new_replica(params = {})
        replica_map.call(params)
      end

      ################# INTERFACE METHODS ######################
      def create_replica(params)
        elektron_share_replicas.post('share-replicas') do
          { share_replica: params }
        end.body['share_replica']
      end

      def resync_replica(id)
        elektron_share_replicas.post("share-replicas/#{id}/action") do
         { resync: true }
        end.body['share_replica']
      end

      def promote_replica(id)
        # byebug
        elektron_share_replicas.post("share-replicas/#{id}/action") do
          { promote: true }
        end.body['share_replica']
      end

      def delete_replica(id)
        elektron_share_replicas.delete("share-replicas/#{id}")
      end
    end
  end
end
