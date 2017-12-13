# frozen_string_literal: true

module ServiceLayerNg
  module SharedFilesystemStorageServices
    # This module implements Openstack Designate Pool API
    module Share
      def shares(filter = {})
        elektron_service.get('shares', filter).map_to('body.shares') do |params|
          SharedFilesystemStorage::ShareNg.new(self, params)
        end
      end

      def shares_detail(filter = {})
        elektron_service.get('shares/detail', filter).map_to('body.shares') do |params|
          SharedFilesystemStorage::ShareNg.new(self, params)
        end
      end

      def find!(share_id)
        elektron_service.get("shares/#{share_id}", filter).map_to('body.shares') do |params|
          SharedFilesystemStorage::ShareNg.new(self, params)
        end
      end

      def find(share_id)
        find!(share_id)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      def new_share(params = {})
        SharedFilesystemStorage::ShareNg.new(self, params)
      end

      def share_types
        types.map_to('body.share_types') do |params|
          SharedFilesystemStorage::ShareTypeNg.new(self, params)
        end
      end

      def share_export_locations(share_id)
        elektron_service.get("shares/#{share_id}/export_locations").map_to(
          'body.export_locations') do |params|
          SharedFilesystemStorage::ShareExportLocationNg.new(self, params)
        end
      end

      def share_volumes
        types.map_to('body.share_volumes') do |params|
          SharedFilesystemStorage::ShareVolumeNg.new(self, params)
        end
      end

      def list_all_major_versions
        elektron_service.get('/').map_to('body.versions' => OpenStruct)
      end

      ################# INTERFACE METHODS ######################
      def create_share(params)
        elektron_service.post('shares') do
          { share: params }
        end.body
      end

      def update_share(share_id, params)
        elektron_service.put("shares/#{share_id}") do
          { share: params }
        end.body['share']
      end

      def delete_share(share_id)
        elektron_service.delete("shares/#{share_id}") do
          { share: params }
        end
      end

      protected

      def types
        @types ||= elektron_service.get('types')
      end
    end
  end
end
