# frozen_string_literal: true

module ServiceLayerNg
  # Implements Openstack Router
  module Router
    def routers(filter = {})
      api.networking.list_routers(filter).map_to(Networking::Router)
    end

    def find_router!(id)
      return nil unless id
      api.networking.show_router_details(id).map_to(Networking::Router)
    end

    def find_router(id)
      find_router!(id).map_to(Networking::Router)
    rescue
      nil
    end

    def new_router(attributes = {})
      map_to(Networking::Router, attributes)
    end

    def add_router_interfaces(router_id,interface_ids)
      interface_ids.each do |interface_id|
        api.networking.add_interface_to_router(
          router_id, subnet_id: interface_id
        )
      end
    end

    def remove_router_interfaces(router_id, interface_ids)
      interface_ids.each do |interface_id|
        api.networking.remove_interface_from_router(
          router_id, subnet_id: interface_id
        )
      end
    end
  end
end
