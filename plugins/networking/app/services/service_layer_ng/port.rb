# frozen_string_literal: true

module ServiceLayerNg
  # Implements Openstack Port
  module Port
    def ports(filter = {})
      api.networking.list_ports(filter).map_to(Networking::Port)
    end

    def find_port!(id)
      return nil unless id
      api.networking.show_port_details(id).map_to(Networking::Port)
    end

    def find_port(id)
      find_port!(id)
    rescue
      nil
    end
  end
end
