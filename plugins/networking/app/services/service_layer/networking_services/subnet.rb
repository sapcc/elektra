# frozen_string_literal: true

module ServiceLayer
  module NetworkingServices
    # Implements Openstack Subnet
    module Subnet
      def subnet_map
        @subnet_map ||= class_map_proc(Networking::Subnet)
      end

      def find_subnet!(id)
        return nil unless id
        elektron_networking.get("subnets/#{id}").map_to(
          "body.subnet",
          &subnet_map
        )
      end

      def find_subnet(id)
        find_subnet!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def new_subnet(attributes = {})
        subnet_map.call(attributes)
      end

      def subnets(filter = {})
        elektron_networking.get("subnets", filter).map_to(
          "body.subnets",
          &subnet_map
        )
      end

      def cached_network_subnets(network_id)
        subnets_data =
          Rails
            .cache
            .fetch("network_#{network_id}_subnets", expires_in: 1.hours) do
              elektron_networking.get("subnets", network_id: network_id).body[
                "subnets"
              ]
            end || []

        subnets_data.collect { |attrs| subnet_map.call(attrs) }
      end

      def cached_subnet(id)
        subnet_data =
          Rails
            .cache
            .fetch("subnet_#{id}", expires_in: 2.hours) do
              begin
                elektron_networking.get("subnets/#{id}").body["subnet"]
              rescue Elektron::Errors::ApiResponse
                nil
              end
            end
        return nil unless subnet_data
        subnet_map.call(subnet_data)
      end

      #################### Model Interface #################
      def create_subnet(attributes)
        elektron_networking.post("subnets") { { "subnet" => attributes } }.body[
          "subnet"
        ]
      end

      def update_subnet(id, attributes)
        elektron_networking
          .put("subnets/#{id}") { { "subnet" => attributes } }
          .body[
          "subnet"
        ]
      end

      def delete_subnet(id)
        elektron_networking.delete("subnets/#{id}")
      end
    end
  end
end
