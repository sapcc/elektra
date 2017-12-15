# frozen_string_literal: true

module ServiceLayerNg
  module BlockStorageServices
    module Volume

      def volume_map
        @volume_map ||= class_map_proc(BlockStorage::VolumeNg)
      end

      def volumes(filter = {})
        elektron_volumes.get('volumes', filter).map_to(
          'body.volumes', &volume_map
        )
      end

      def volumes_detail(filter = {})
        elektron_volumes.get('volumes/detail', filter).map_to(
          'body.volumes', &volume_map
        )
      end

      def find_volume!(id)
        return nil if id.blank?
        elektron_volumes.get("volumes/#{id}").map_to('body.volume', &volume_map)
      end

      def find_volume(id)
        find_volume!(id)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      def new_volume(params = {})
        volume_map.call(params)
      end

      ################## MODEL INTERFACE METHODS ####################
      def create_volume_ng(params = {})
        elektron_volumes.post('volumes') do
          { volume: params }
        end.body['volume']
      end

      def update_volume_ng(id, params = {})
        elektron_volumes.put("volumes/#{id}") do
          { volume: params }
        end.body['volume']
      end

      def delete_volume_ng(id)
        elektron_volumes.delete("volumes/#{id}")
      end
    end
  end
end
