# frozen_string_literal: true

module ServiceLayer
  module SharedFilesystemStorageServices
    # This module implements Openstack Designate Pool API
    module ShareNetwork
      def share_network_map
        @share_network_map ||=
          class_map_proc(SharedFilesystemStorage::ShareNetwork)
      end

      def share_networks(filter = {})
        elektron_shares.get("share-networks", filter).map_to(
          "body.share_networks",
          &share_network_map
        )
      end

      def share_networks_detail(filter = {})
        elektron_shares.get("share-networks/detail", filter).map_to(
          "body.share_networks",
          &share_network_map
        )
      end

      def new_share_network(params = {})
        share_network_map.call(params)
      end

      def find_share_network!(id)
        elektron_shares.get("share-networks/#{id}", filter).map_to(
          "body.share_network",
          &share_network_map
        )
      end

      def find_share_network(id)
        find_share_network(id)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      def add_security_service_to_share_network(security_service_id, id)
        elektron_shares
          .post("share-networks/#{id}/action") do
            {
              add_security_service: {
                security_service_id: security_service_id,
              },
            }
          end
          .body[
          "share_network"
        ]
      end

      def remove_security_service_from_share_network(security_service_id, id)
        elektron_shares
          .post("share-networks/#{id}/action") do
            {
              remove_security_service: {
                security_service_id: security_service_id,
              },
            }
          end
          .body[
          "share_network"
        ]
      end

      # ################# INTERFACE METHODS ######################
      def create_share_network(params)
        elektron_shares
          .post("share-networks") { { share_network: params } }
          .body[
          "share_network"
        ]
      end

      def update_share_network(id, params)
        elektron_shares
          .put("share-networks/#{id}") { { share_network: params } }
          .body[
          "share_network"
        ]
      end

      def delete_share_network(id)
        elektron_shares.delete("share-networks/#{id}")
      end
    end
  end
end
