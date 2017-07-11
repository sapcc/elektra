# frozen_string_literal: true

module ServiceLayerNg
  # Implements Openstack Subnet
  module Subnet
    def find_subnet!(id)
      return nil unless id
      api.networking.show_subnet_details(id).map_to(Networking::Subnet)
    end

    def find_subnet(id)
      find_subnet!(id)
    rescue
      nil
    end

    def new_subnet(attributes = {})
      map_to(Networking::Subnet, attributes)
    end

    def subnets(filter = {})
      api.networking.list_subnets(filter).map_to(Networking::Subnet)
    end

    def cached_network_subnets(network_id)
      subnets_data = Rails.cache.fetch(
        "network_#{network_id}_subnets", expires_in: 1.hours
      ) do
        api.networking.subnets(network_id: network_id).data
      end || []
      subnets_data.collect { |attrs| map_to(Networking::Subnet, attrs) }
    end

    def cached_subnet(id)
      subnet_data = Rails.cache.fetch("subnet_#{id}", expires_in: 2.hours) do
        api.networking.show_subnet_details(id).data
      end
      map_to(Networking::Subnet, subnet_data)
    end
  end
end
